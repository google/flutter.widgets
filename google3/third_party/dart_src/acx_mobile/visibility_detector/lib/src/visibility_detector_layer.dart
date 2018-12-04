// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:async' show Timer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'visibility_detector.dart';
import 'visibility_detector_controller.dart';

/// Returns a sequence containing the specified [Layer] and all of its
/// ancestors.  The returned sequence is in [parent, child] order.
Iterable<Layer> _getLayerChain(Layer start) {
  final List<Layer> layerChain = <Layer>[];
  for (Layer layer = start; layer != null; layer = layer.parent) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

/// Returns the accumulated transform from the specified sequence of [Layer]s.
/// The sequence must be in [parent, child] order.  The sequence must not be
/// null.
Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {
  assert(layerChain != null);

  Matrix4 transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    Layer parent = layerChain.first;
    for (Layer child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}

/// Converts a [Rect] in local coordinates of the specified [Layer] to a new
/// [Rect] in global coordinates.
Rect _localRectToGlobal(Layer layer, Rect localRect) {
  final Iterable<Layer> layerChain = _getLayerChain(layer);

  // Skip the root layer which transforms from logical pixels to physical
  // device pixels.
  assert(layerChain.isNotEmpty);
  assert(layerChain.first is TransformLayer);
  final Matrix4 transform = _accumulateTransforms(layerChain.skip(1));
  return MatrixUtils.transformRect(transform, localRect);
}

/// The [Layer] corresponding to a [VisibilityDetector] widget.
///
/// We use a [Layer] because we can directly determine visibility by virtue of
/// being added to the [SceneBuilder].
class VisibilityDetectorLayer extends ContainerLayer {
  /// Constructor.  See the corresponding properties for parameter details.
  VisibilityDetectorLayer(
      {@required this.key,
      @required this.widgetSize,
      @required this.paintOffset,
      @required this.onVisibilityChanged})
      : _layerOffset = Offset.zero {
    assert(key != null);
    assert(paintOffset != null);
    assert(widgetSize != null);
    assert(onVisibilityChanged != null);
  }

  /// Timer used by [_scheduleUpdate].
  static Timer _timer;

  /// Keeps track of [VisibilityDetectorLayer] objects that have been recently
  /// updated and that might need to report visibility changes.  Additionally
  /// maps [VisibilityDetector] keys to the most recently added
  /// [VisibilityDetectorLayer] that corresponds to it; this mapping is
  /// necessary in case a layout change causes a new layer to be instantiated
  /// for an existing key.
  static final Map<Key, VisibilityDetectorLayer> _updated =
      <Key, VisibilityDetectorLayer>{};

  /// Keeps track of the last known visibility state of a [VisibilityDetector].
  /// This is used to suppress extraneous callbacks when visibility hasn't
  /// changed.  Stores entries only for visible [VisibilityDetector] objects;
  /// entries for non-visible ones are actively removed.  See [_fireCallback].
  static final Map<Key, VisibilityInfo> _lastVisibility =
      <Key, VisibilityInfo>{};

  /// The key for the corresponding [VisibilityDetector] widget.  Never null.
  final Key key;

  /// The size of the corresponding [VisibilityDetector] widget.  Never null.
  final Size widgetSize;

  /// Last known layer offset supplied to [addToScene].  Never null.
  Offset _layerOffset;

  /// The offset supplied to [RenderVisibilityDetector.paint] method.  Never
  /// null.
  final Offset paintOffset;

  /// See [VisibilityDetector.onVisibilityChanged].  Do not invoke this
  /// directly; call [_fireCallback] instead.  Never null.
  final VisibilityChangedCallback onVisibilityChanged;

  /// Computes the bounds for the corresponding [VisibilityDetector] widget, in
  /// global coordinates.
  Rect _computeWidgetBounds() {
    final Rect r = _localRectToGlobal(this, Offset.zero & widgetSize);
    return r.shift(paintOffset + _layerOffset);
  }

  /// Computes the accumulated clipping bounds, in global coordinates.
  Rect _computeClipRect() {
    final Size screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    Rect clipRect = Offset.zero & screenSize;

    ContainerLayer parentLayer = parent;
    while (parentLayer != null) {
      Rect curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath.getBounds();
      }

      if (curClipRect != null) {
        // This is O(n^2) WRT the depth of the tree since `_localRectToGlobal`
        // also walks up the tree.  In practice there probably will be a small
        // number of clipping layers in the chain, so it might not be a problem.
        // Alternatively we could cache transformations and clipping rectangles.
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  /// Schedules a timer to invoke the visibility callbacks.  The timer is used
  /// to throttle and coalesce updates.
  void _scheduleUpdate() {
    _updated[key] = this;

    if (_timer == null) {
      // We use a normal [Timer] instead of a [RestartableTimer] so that changes
      // to the update duration will be picked up automatically.
      _timer = Timer(
          VisibilityDetectorController.instance.updateInterval, _handleTimer);
    } else {
      assert(_timer.isActive);
    }
  }

  /// [Timer] callback.  Defers visibility callbacks to execute after the next
  /// frame.
  static void _handleTimer() {
    _timer = null;

    // Ensure that work is done between frames so that calculations are
    // performed from a consistent state.  We use `scheduleTask<T>` here instead
    // of `addPostFrameCallback` or `scheduleFrameCallback` so that work will
    // be done without unnecessarily scheduling a new frame.
    SchedulerBinding.instance.scheduleTask(_processCallbacks, Priority.touch);
  }

  /// See [VisibilityDetector.notifyNow].
  static void notifyNow() {
    if (_timer == null) {
      assert(_updated.isEmpty);
      return;
    }

    _timer.cancel();
    _timer = null;
    _processCallbacks();
  }

  /// Executes visibility callbacks for all updated [VisibilityDetectorLayer]
  /// instances.
  static void _processCallbacks() {
    for (VisibilityDetectorLayer layer in _updated.values) {
      if (!layer.attached) {
        layer._fireCallback(VisibilityInfo(
            key: layer.key, size: _lastVisibility[layer.key]?.size));
        continue;
      }

      final info = VisibilityInfo.fromRects(
          key: layer.key,
          widgetBounds: layer._computeWidgetBounds(),
          clipRect: layer._computeClipRect());
      layer._fireCallback(info);
    }
    _updated.clear();
  }

  /// Invokes the visibility callback if [VisibilityInfo] hasn't meaningfully
  /// changed since the last time we invoked it.
  void _fireCallback(VisibilityInfo info) {
    assert(info != null);

    final VisibilityInfo oldInfo = _lastVisibility[key];
    final bool visible = !info.visibleBounds.isEmpty;

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
      // Only keep visible items in the map so that it doesn't grow unbounded.
      _lastVisibility.remove(key);
    }

    onVisibilityChanged(info);
  }

  /// See [Layer.addToScene].
  @override
  ui.EngineLayer addToScene(ui.SceneBuilder builder,
      [Offset layerOffset = Offset.zero]) {
    _layerOffset = layerOffset;
    _scheduleUpdate();
    return super.addToScene(builder, paintOffset + layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
    super.attach(owner);
    _scheduleUpdate();
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    _scheduleUpdate();
  }

  /// See [Diagnosticable.debugFillProperties].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<Key>('key', key));
    properties
        .add(DiagnosticsProperty<Rect>('widgetRect', _computeWidgetBounds()));
    properties.add(DiagnosticsProperty<Rect>('clipRect', _computeClipRect()));
  }
}
