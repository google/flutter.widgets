// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_widgets/src/visibility_detector/visibility_detector.dart';

void _expectVisibility(Rect widgetBounds, Rect clipRect,
    Rect expectedVisibleBounds, double expectedVisibleFraction) {
  final info = VisibilityInfo.fromRects(
      key: UniqueKey(), widgetBounds: widgetBounds, clipRect: clipRect);
  expect(info.size, widgetBounds.size);
  expect(info.visibleBounds, expectedVisibleBounds);
  expect(info.visibleFraction, expectedVisibleFraction);
}

void main() {
  final clipRect = Rect.fromLTWH(100, 200, 300, 400);

  test('VisibilityInfo: not visible', () {
    final widgetBounds = Rect.fromLTWH(15, 25, 10, 20);
    final expectedVisibleBounds = Rect.zero;
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0);
  });

  test('VisibilityInfo: fully visible', () {
    final widgetBounds = Rect.fromLTWH(115, 225, 10, 20);
    final expectedVisibleBounds = Rect.fromLTWH(0, 0, 10, 20);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 1);
  });

  test('VisibilityInfo: partially visible (1 edge offscreen)', () {
    final widgetBounds = Rect.fromLTWH(115, 195, 10, 20);
    final expectedVisibleBounds = Rect.fromLTWH(0, 5, 10, 15);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0.75);
  });

  test('VisibilityInfo: partially visible (2 edges offscreen)', () {
    final widgetBounds = Rect.fromLTWH(99, 195, 10, 20);
    final expectedVisibleBounds = Rect.fromLTWH(1, 5, 9, 15);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0.675);
  });

  test('VisibilityInfo: partially visible (3 edges offscreen)', () {
    final widgetBounds = Rect.fromLTWH(99, 195, 500, 20);
    final expectedVisibleBounds = Rect.fromLTWH(1, 5, 300, 15);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0.45);
  });

  test('VisibilityInfo: partially visible (4 edges offscreen)', () {
    final widgetBounds = Rect.fromLTWH(99, 195, 500, 600);
    final expectedVisibleBounds = Rect.fromLTWH(1, 5, 300, 400);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0.4);
  });

  test('VisibilityInfo: visibility ~0%', () {
    final widgetBounds = Rect.fromLTWH(100, 599, 300, 400);
    final expectedVisibleBounds = Rect.fromLTWH(0, 0, 300, 1);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 0);
  });

  test('VisibilityInfo: visibility ~100%', () {
    final widgetBounds = Rect.fromLTWH(100, 200, 300, 399);
    final expectedVisibleBounds = Rect.fromLTWH(0, 0, 300, 399);
    _expectVisibility(widgetBounds, clipRect, expectedVisibleBounds, 1);
  });
}
