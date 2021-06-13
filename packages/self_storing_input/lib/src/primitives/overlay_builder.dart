// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:math';

import 'package:flutter/material.dart';

import 'overlay.dart';

/// Creates an overlay with top left corner
/// in the middle of the [context]'s render box,
/// if area size allows.
OverlayEntry createOverlayInTheMiddle(
  Widget content,
  BuildContext context,
  OverlayStyle style,
) {
  RenderBox renderBox = context.findRenderObject() as RenderBox;
  var offset = renderBox.localToGlobal(Offset.zero);

  return OverlayEntry(
    builder: (context) => Positioned(
      left: _getOverlayPosition(
        target: offset.dx + renderBox.size.width / 2,
        overlaySize: style.width,
        areaSize: MediaQuery.of(context).size.width,
      ),
      top: _getOverlayPosition(
        target: offset.dy + renderBox.size.height / 2,
        overlaySize: style.height,
        areaSize: MediaQuery.of(context).size.height,
      ),
      child: applyOverlayStyle(style, content),
    ),
  );
}

/// Applies overlay style to the provided overlay content.
Widget applyOverlayStyle(OverlayStyle style, Widget child) {
  return Material(
    elevation: style.elevation,
    child: Container(
      width: style.width,
      height: style.height,
      margin: EdgeInsets.symmetric(horizontal: style.margin),
      child: child,
    ),
  );
}

/// Calculates the overlay position for one dimension.
///
/// The preferred position of the overlay is to place
/// its top-left corner in the [target].
/// The overlay position will be adjusted, if necessary,
/// to fit on the screen if possible.
double _getOverlayPosition({
  required double target,
  required double overlaySize,
  required double areaSize,
}) {
  if (target + overlaySize <= areaSize) {
    return target;
  }
  return max(0, areaSize - overlaySize);
}
