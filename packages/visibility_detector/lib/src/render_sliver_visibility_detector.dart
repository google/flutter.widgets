// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'visibility_detector.dart';
import 'visibility_detector_layer.dart';

/// The [RenderObject] corresponding to the [SliverVisibilityDetector] widget.
///
/// [RenderSliverVisibilityDetector] is a bridge between
/// [SliverVisibilityDetector] and [VisibilityDetectorLayer].
class RenderSliverVisibilityDetector extends RenderProxySliver {
  /// Constructor.  See the corresponding properties for parameter details.
  RenderSliverVisibilityDetector({
    RenderSliver? sliver,
    required this.key,
    required VisibilityChangedCallback? onVisibilityChanged,
  })   : _onVisibilityChanged = onVisibilityChanged,
        super(sliver);

  /// The key for the corresponding [VisibilityDetector] widget.
  final Key key;

  VisibilityChangedCallback? _onVisibilityChanged;

  /// See [VisibilityDetector.onVisibilityChanged].
  VisibilityChangedCallback? get onVisibilityChanged => _onVisibilityChanged;

  /// Used by [VisibilityDetector.updateRenderObject].
  set onVisibilityChanged(VisibilityChangedCallback? value) {
    _onVisibilityChanged = value;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  // See [RenderObject.alwaysNeedsCompositing].
  @override
  bool get alwaysNeedsCompositing => onVisibilityChanged != null;

  /// See [RenderObject.paint].
  @override
  void paint(PaintingContext context, Offset offset) {
    if (onVisibilityChanged == null) {
      // No need to create a [VisibilityDetectorLayer].  However, in case one
      // already exists, remove all cached data for it so that we won't fire
      // visibility callbacks when the layer is removed.
      VisibilityDetectorLayer.forget(key);
      super.paint(context, offset);
      return;
    }

    Rect widgetRect;
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.down:
        widgetRect = Offset(0, -constraints.scrollOffset) &
            Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.up:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetRect = Offset(0, min(startOffset, 0)) &
            Size(constraints.crossAxisExtent, geometry!.scrollExtent);
        break;
      case AxisDirection.right:
        widgetRect = Offset(-constraints.scrollOffset, 0) &
            Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
      case AxisDirection.left:
        final startOffset = geometry!.paintExtent +
            constraints.scrollOffset -
            geometry!.scrollExtent;
        widgetRect = Offset(min(startOffset, 0), 0) &
            Size(geometry!.scrollExtent, constraints.crossAxisExtent);
        break;
    }

    final layer = VisibilityDetectorLayer(
        key: key,
        widgetRect: widgetRect,
        paintOffset: offset,
        onVisibilityChanged: onVisibilityChanged!);
    context.pushLayer(layer, super.paint, offset);
  }
}
