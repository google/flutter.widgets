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
    _lastVisibility.remove(key);

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

  void _fireCallback(ContainerLayer? layer, Rect bounds) {
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
    } else {
      markNeedsPaint();
      // If an update is happening and some ancestor no longer paints this RO,
      // the markNeedsPaint above will never cause the composition callback to
      // fire and we could miss a hide event. This schedule will get
      // over-written by subsequent updates in paint, if paint is called.
      _scheduleUpdate();
    }
  }

  int _debugScheduleUpdateCount = 0;

  /// The number of times the schedule update callback has been invoked from
  /// [Layer.addCompositionCallback].
  ///
  /// This is used for testing, and always returns null outside of debug mode.
  @visibleForTesting
  int? get debugScheduleUpdateCount {
    if (kDebugMode) {
      return _debugScheduleUpdateCount;
    }
    return null;
  }

  void _scheduleUpdate([ContainerLayer? layer]) {
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

  VisibilityInfo _determineVisibility(ContainerLayer? layer, Rect bounds) {
    if (_disposed || layer == null || layer.attached == false || !attached) {
      // layer is detached and thus invisible.
      return VisibilityInfo(
        key: key,
        size: _lastVisibility[key]?.size ?? Size.zero,
      );
    }
    final transform = Matrix4.identity();

    // Check if any ancestors decided to skip painting this RenderObject.
    if (parent != null) {
      RenderObject ancestor = parent! as RenderObject;
      RenderObject child = this;
      while (ancestor.parent != null) {
        if (!ancestor.paintsChild(child)) {
          return VisibilityInfo(key: key, size: bounds.size);
        }
        child = ancestor;
        ancestor = ancestor.parent! as RenderObject;
      }
    }

    // Create a list of Layers from layer to the root, excluding the root
    // since that has the DPR transform and we want to work with logical pixels.
    // Add one extra leaf layer so that we can apply the transform of `layer`
    // to the matrix.
    ContainerLayer? ancestor = layer;
    final List<ContainerLayer> ancestors = <ContainerLayer>[ContainerLayer()];
    while (ancestor != null && ancestor.parent != null) {
      ancestors.add(ancestor);
      ancestor = ancestor.parent;
    }

    Rect clip = Rect.largest;
    for (int index = ancestors.length - 1; index > 0; index -= 1) {
      final parent = ancestors[index];
      final child = ancestors[index - 1];
      Rect? parentClip = parent.describeClipBounds();
      if (parentClip != null) {
        clip = clip.intersect(MatrixUtils.transformRect(transform, parentClip));
      }
      parent.applyTransform(child, transform);
    }

    // Apply whatever transform/clip was on the canvas when painting.
    if (_lastPaintClipBounds != null) {
      clip = clip.intersect(MatrixUtils.transformRect(
        transform,
        _lastPaintClipBounds!,
      ));
    }
    if (_lastPaintTransform != null) {
      transform.multiply(_lastPaintTransform!);
    }
    return VisibilityInfo.fromRects(
      key: key,
      widgetBounds: MatrixUtils.transformRect(transform, bounds),
      clipRect: clip,
    );
  }

  /// Used to get the bounds of the render object when it is time to update
  /// clients about visibility.
  Rect get bounds;

  Matrix4? _lastPaintTransform;
  Rect? _lastPaintClipBounds;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged != null) {
      _lastPaintClipBounds = context.canvas.getLocalClipBounds();
      _lastPaintTransform =
          Matrix4.fromFloat64List(context.canvas.getTransform())
            ..translate(offset.dx, offset.dy, 0);

      _compositionCallbackCanceller?.call();
      _compositionCallbackCanceller =
          context.addCompositionCallback((Layer layer) {
        assert(!debugDisposed!);
        final ContainerLayer? container =
            layer is ContainerLayer ? layer : layer.parent;
        _scheduleUpdate(container);
      });
    }
    super.paint(context, offset);
  }

  bool _disposed = false;
  @override
  void dispose() {
    _compositionCallbackCanceller?.call();
    _compositionCallbackCanceller = null;
    _disposed = true;
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

  @override
  Rect get bounds => semanticBounds;
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

  @override
  Rect get bounds {
    Size widgetSize;
    Offset widgetOffset;
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.down:
        widgetOffset = Offset(0, -constraints.scrollOffset);
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.up:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(0, math.min(startOffset, 0));
        widgetSize = Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.right:
        widgetOffset = Offset(-constraints.scrollOffset, 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
      case AxisDirection.left:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetOffset = Offset(math.min(startOffset, 0), 0);
        widgetSize = Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
    }
    return widgetOffset & widgetSize;
  }
}
