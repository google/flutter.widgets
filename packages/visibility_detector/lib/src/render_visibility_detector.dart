// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'visibility_detector.dart';
import 'visibility_detector_controller.dart';

mixin RenderVisibilityDetectorBase on RenderObject {
  static int? get debugUpdateCount {
    if (!kDebugMode) {
      return null;
    }
    return _updates.length;
  }

  static Map<Key, VoidCallback> _updates = <Key, VoidCallback>{};
  static Map<Key, VisibilityInfo> _lastVisibility = <Key, VisibilityInfo>{};

  /// See [VisibilityDetectorController.notifyNow].
  static void notifyNow() {
    _timer?.cancel();
    _timer = null;
    _processCallbacks();
  }

  static void forget(Key key) {
    _updates.remove(key);

    if (_updates.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  static Timer? _timer;
  static void _handleTimer() {
    _timer = null;
    // Ensure that work is done between frames so that calculations are
    // performed from a consistent state.  We use `scheduleTask<T>` here instead
    // of `addPostFrameCallback` or `scheduleFrameCallback` so that work will
    // be done even if a new frame isn't scheduled and without unnecessarily
    // scheduling a new frame.
    SchedulerBinding.instance.scheduleTask<void>(
      _processCallbacks,
      Priority.touch,
    );
  }

  /// Executes visibility callbacks for all updated instances.
  static void _processCallbacks() {
    for (final callback in _updates.values) {
      callback();
    }
    _updates.clear();
  }

  void _fireCallback(ContainerLayer layer, Rect bounds) {
    final oldInfo = _lastVisibility[key];
    final info = _determineVisibility(layer, bounds);
    final visible = !info.visibleBounds.isEmpty;

    if (oldInfo == null) {
      if (!visible) {
        return;
      }
    } else if (info.matchesVisibility(oldInfo)) {
      return;
    }

    if (visible) {
      _lastVisibility[key] = info;
    } else {
      // Track only visible items so that the map does not grow unbounded.
      _lastVisibility.remove(key);
    }

    onVisibilityChanged?.call(info);
  }

  /// The key for the corresponding [VisibilityDetector] widget.
  Key get key;

  VoidCallback? _compositionCallbackCanceller;

  VisibilityChangedCallback? _onVisibilityChanged;

  /// See [VisibilityDetector.onVisibilityChanged].
  VisibilityChangedCallback? get onVisibilityChanged => _onVisibilityChanged;

  /// Used by [VisibilityDetector.updateRenderObject].
  set onVisibilityChanged(VisibilityChangedCallback? value) {
    if (_onVisibilityChanged == value) {
      return;
    }
    _compositionCallbackCanceller?.call();
    _compositionCallbackCanceller = null;
    _onVisibilityChanged = value;
    if (value == null) {
      // Remove all cached data so that we won't fire visibility callbacks when
      // a timer expires or get stale old information the next time around.
      forget(key);
      _lastVisibility.remove(key);
    } else {
      markNeedsPaint();
    }
  }

  static final Map<RenderObject, List<RenderObject>> _cachedAncestorLists =
      <RenderObject, List<RenderObject>>{};

  int _debugScheduleUpdateCount = 0;

  /// The number of times the schedule update callback has been invoked from
  /// [Layer.addCompositionCallback].
  ///
  /// This is used for testing, and always returns 0 outside of debug mode.
  @visibleForTesting
  int? get debugScheduleUpdateCount {
    if (kDebugMode) {
      return _debugScheduleUpdateCount;
    }
    return 0;
  }

  void _scheduleUpdate(ContainerLayer layer, Rect bounds) {
    if (kDebugMode) {
      _debugScheduleUpdateCount += 1;
    }
    bool isFirstUpdate = _updates.isEmpty;
    _updates[key] = () {
      _fireCallback(layer, bounds);
    };
    final updateInterval = VisibilityDetectorController.instance.updateInterval;
    if (updateInterval == Duration.zero) {
      // Even with [Duration.zero], we still want to defer callbacks to the end
      // of the frame so that they're processed from a consistent state.  This
      // also ensures that they don't mutate the widget tree while we're in the
      // middle of a frame.
      if (isFirstUpdate) {
        // We're about to render a frame, so a post-frame callback is guaranteed
        // to fire and will give us the better immediacy than `scheduleTask<T>`.
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          _processCallbacks();
        });
      }
    } else if (_timer == null) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer!.isActive);
    }
  }

  VisibilityInfo _determineVisibility(ContainerLayer layer, Rect bounds) {
    if (_disposed || !layer.attached || !attached) {
      _cachedAncestorLists.remove(this);
      // layer is detached and thus invisible.
      return VisibilityInfo(
        key: key,
        size: _lastVisibility[key]?.size ?? Size.zero,
      );
    }
    final transform = Matrix4.identity();

    // Create a list of RenderObjects from this to the root, excluding the root
    // since that has the DPR transform and we want to work with logical pixels.
    // Cannot use the layer tree since some ancestor render object may have
    // directly transformed/clipped the canvas. If there is some way to figure
    // out how to get the RenderObjects below [layer], could take advantage of
    // the usually shallower height of the layer tree compared to the render
    // tree. Alternatively, if the canvas itself exposed the current matrix/clip
    // we could use that.
    RenderObject? ancestor = parent as RenderObject?;

    final List<RenderObject> ancestors = <RenderObject>[];
    if (ancestors.isEmpty && ancestor != null) {
      _cachedAncestorLists[ancestor] = ancestors;
      while (ancestor != null && ancestor.parent != null) {
        ancestors.add(ancestor);
        ancestor = ancestor.parent as RenderObject?;
      }
    }

    // Determine the transform and clip from first child of root down to
    // this.
    Rect clip = Rect.largest;
    for (int index = ancestors.length - 1; index > 0; index -= 1) {
      final parent = ancestors[index];
      final child = ancestors[index - 1];
      parent.applyPaintTransform(child, transform);
      Rect? parentClip = parent.describeApproximatePaintClip(child);
      if (parentClip != null) {
        clip = clip.intersect(MatrixUtils.transformRect(transform, parentClip));
      }
    }
    return VisibilityInfo.fromRects(
      key: key,
      widgetBounds: MatrixUtils.transformRect(transform, bounds),
      clipRect: clip,
    );
  }

  bool _disposed = false;
  @override
  void dispose() {
    _compositionCallbackCanceller?.call();
    _compositionCallbackCanceller = null;
    _disposed = true;
    _cachedAncestorLists.remove(this);
    super.dispose();
  }
}

/// The [RenderObject] corresponding to the [VisibilityDetector] widget.
class RenderVisibilityDetector extends RenderProxyBox
    with RenderVisibilityDetectorBase {
  /// Constructor.  See the corresponding properties for parameter details.
  RenderVisibilityDetector({
    RenderBox? child,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  })  : assert(key != null),
        super(child) {
    _onVisibilityChanged = onVisibilityChanged;
  }

  @override
  final Key key;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged != null) {
      _compositionCallbackCanceller?.call();
      _compositionCallbackCanceller =
          context.addCompositionCallback((ContainerLayer layer) {
        assert(!debugDisposed!);
        _scheduleUpdate(layer, offset & semanticBounds.size);
      });
    }
    super.paint(context, offset);
  }
}

/// The [RenderObject] corresponding to the [SliverVisibilityDetector] widget.
///
/// [RenderSliverVisibilityDetector] is a bridge between
/// [SliverVisibilityDetector] and [VisibilityDetectorLayer].
class RenderSliverVisibilityDetector extends RenderProxySliver
    with RenderVisibilityDetectorBase {
  /// Constructor.  See the corresponding properties for parameter details.
  RenderSliverVisibilityDetector({
    RenderSliver? sliver,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  }) : super(sliver) {
    _onVisibilityChanged = onVisibilityChanged;
  }

  @override
  final Key key;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged != null) {
      _compositionCallbackCanceller?.call();
      _compositionCallbackCanceller =
          context.addCompositionCallback((ContainerLayer layer) {
        assert(!debugDisposed!);

        Size widgetSize;
        Offset widgetOffset;
        switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection,
          constraints.growthDirection,
        )) {
          case AxisDirection.down:
            widgetOffset = Offset(0, -constraints.scrollOffset);
            widgetSize =
                Size(constraints.crossAxisExtent, geometry!.scrollExtent);
            break;
          case AxisDirection.up:
            final startOffset = geometry!.paintExtent +
                constraints.scrollOffset -
                geometry!.scrollExtent;
            widgetOffset = Offset(0, math.min(startOffset, 0));
            widgetSize =
                Size(constraints.crossAxisExtent, geometry!.scrollExtent);
            break;
          case AxisDirection.right:
            widgetOffset = Offset(-constraints.scrollOffset, 0);
            widgetSize =
                Size(geometry!.scrollExtent, constraints.crossAxisExtent);
            break;
          case AxisDirection.left:
            final startOffset = geometry!.paintExtent +
                constraints.scrollOffset -
                geometry!.scrollExtent;
            widgetOffset = Offset(math.min(startOffset, 0), 0);
            widgetSize =
                Size(geometry!.scrollExtent, constraints.crossAxisExtent);
            break;
        }
        _scheduleUpdate(layer, offset + widgetOffset & widgetSize);
      });
    }
    super.paint(context, offset);
  }
}
