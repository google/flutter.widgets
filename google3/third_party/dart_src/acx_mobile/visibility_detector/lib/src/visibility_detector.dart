// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math' show max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'render_visibility_detector.dart';

/// A [VisibilityDetector] widget fires a specified callback when the widget
/// changes visibility.
///
/// Callbacks are not fired immediately on visibility changes.  Callbacks are
/// deferred and coalesced such that the callback for each [VisibilityDetector]
/// will be invoked at most once per [updateInterval].  Callbacks for *all*
/// [VisibilityDetector] widgets are fired together synchronously between
/// frames.
class VisibilityDetector extends SingleChildRenderObjectWidget {
  /// Constructor.
  ///
  /// `key` is required to properly identify this widget; it must be unique
  /// among all [VisibilityDetector] widgets.
  ///
  /// `child` must not be null.
  ///
  /// `onVisibilityChanged` may be null to disable this [VisibilityDetector].
  VisibilityDetector({
    @required Key key,
    @required Widget child,
    @required this.onVisibilityChanged,
  }) : super(key: key, child: child) {
    assert(key != null);
    assert(child != null);
  }

  /// The callback to invoke when this widget's visibility changes.
  final VisibilityChangedCallback onVisibilityChanged;

  /// The minimum amount of time to wait between firing batches of visibility
  /// callbacks.
  static Duration updateInterval = Duration(milliseconds: 500);

  /// See [RenderObjectWidget.createRenderObject].
  @override
  RenderVisibilityDetector createRenderObject(BuildContext context) {
    return RenderVisibilityDetector(
      key: key,
      onVisibilityChanged: onVisibilityChanged,
    );
  }

  /// See [RenderObjectWidget.updateRenderObject].
  @override
  void updateRenderObject(
      BuildContext context, RenderVisibilityDetector renderObject) {
    assert(renderObject.key == key);
    renderObject.onVisibilityChanged = onVisibilityChanged;
  }
}

typedef VisibilityChangedCallback = void Function(VisibilityInfo info);

/// Data passed to the [VisibilityDetector.onVisibilityChanged] callback.
@immutable
class VisibilityInfo {
  /// Constructor.
  ///
  /// `key` corresponds to the [Key] used to construct the corresponding
  /// [VisibilityDetector] widget.  Must not be null.
  ///
  /// If `size` or `visibleBounds` are omitted or null, the [VisibilityInfo]
  /// will be initialized to [Offset.zero] or [Rect.zero] respectively.  This
  /// will indicate that the corresponding widget is competely hidden.
  VisibilityInfo({@required this.key, Size size, Rect visibleBounds})
      : size = size ?? Size.zero,
        visibleBounds = visibleBounds ?? Rect.zero {
    assert(key != null);
  }

  factory VisibilityInfo.fromRects({
    @required Key key,
    @required Rect widgetBounds,
    @required Rect clipRect,
  }) {
    assert(widgetBounds != null);
    assert(clipRect != null);

    // Compute the intersection in the widget's local coordinates.
    final Rect visibleBounds = widgetBounds.overlaps(clipRect)
        ? widgetBounds.intersect(clipRect).shift(-widgetBounds.topLeft)
        : Rect.zero;

    return VisibilityInfo(
        key: key, size: widgetBounds.size, visibleBounds: visibleBounds);
  }

  /// The key for the corresponding [VisibilityDetector] widget.  Never null.
  final Key key;

  /// The size of the widget.  Never null.
  final Size size;

  /// The visible portion of the widget, in the widget's local coordinates.
  /// Never null.
  final Rect visibleBounds;

  /// A fraction in the range [0, 1] that represents what proportion of the
  /// widget is visible (assuming rectangular bounding boxes).  0 means not
  /// visible; 1 means fully visible.
  double get visibleFraction {
    final double visibleArea = _area(visibleBounds.size);
    final double maxVisibleArea = _area(size);

    if (_floatNear(maxVisibleArea, 0)) {
      // Avoid division-by-zero.
      return 0;
    }

    double visibleFraction = visibleArea / maxVisibleArea;

    if (_floatNear(visibleFraction, 0)) {
      visibleFraction = 0;
    } else if (_floatNear(visibleFraction, 1)) {
      // The inexact nature of floating-point arithmetic means that sometimes
      // the visible area might never equal the maximum area (or could even
      // be slightly larger than the maximum).  Snap to the maximum.
      visibleFraction = 1;
    }

    assert(visibleFraction >= 0);
    assert(visibleFraction <= 1);
    return visibleFraction;
  }

  /// Returns true if the specified [VisibilityInfo] object has equivalent
  /// visibility to this one.
  bool matchesVisibility(VisibilityInfo info) {
    // We don't override `operator ==` so that object equality can be separate
    // from whether two [VisibilityInfo] objects are sufficiently similar
    // that we don't need to fire callbacks for both.  This could be pertinent
    // if other properties are added.
    assert(info != null);
    return size == info.size && visibleBounds == info.visibleBounds;
  }
}

/// The tolerance used to determine whether two floating-point values are
/// approximately equal.
const _kDefaultTolerance = 0.01;

/// Computes the area of a rectangle of the specified dimensions.
double _area(Size size) {
  assert(size != null);
  assert(size.width >= 0);
  assert(size.height >= 0);
  return size.width * size.height;
}

/// Returns whether two floating-point values are approximately equal.
bool _floatNear(double f1, double f2) {
  double absDiff = (f1 - f2).abs();
  return absDiff <= _kDefaultTolerance ||
      (absDiff / max(f1.abs(), f2.abs()) <= _kDefaultTolerance);
}
