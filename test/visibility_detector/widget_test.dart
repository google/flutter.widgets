// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widgets/src/visibility_detector/visibility_detector.dart';
import 'package:flutter_widgets/src/visibility_detector/demo.dart' as demo;

/// Maps [row, column] indices to the last reported [VisibilityInfo] for the
/// corresponding [VisibilityDetector] widget in the demo app.
final _positionToVisibilityInfo = <demo.RowColumn, VisibilityInfo>{};

void main() {
  demo.visibilityListeners.add((demo.RowColumn rc, VisibilityInfo info) {
    _positionToVisibilityInfo[rc] = info;
  });

  tearDown(() {
    _positionToVisibilityInfo.clear();
  });

  _wrapTest('VisibilityDetector build', (tester) async {
    expect(find.byType(ErrorWidget), findsNothing);

    final Finder cell = find.byKey(demo.cellKey(0, 0));
    expect(cell, findsOneWidget);
  });

  _wrapTest('VisibilityDetector initially visible', (tester) async {
    final Finder cell = find.byKey(demo.cellKey(0, 0));
    final Rect expectedRect = tester.getRect(cell);

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
    expect(info.size, expectedRect.size);
    expect(info.size.width > 0, true);
    expect(info.size.height > 0, true);
    expect(info.size.height, demo.kRowHeight - 2 * demo.kRowPadding);
    expect(info.visibleBounds, Offset.zero & info.size);
    expect(info.visibleFraction, 1.0);
  });

  _wrapTest('VisibilityDetector vertically scrolled partially offscreen',
      (tester) async {
    final Finder mainList = find.byKey(demo.mainListKey);
    expect(mainList, findsOneWidget);
    final Rect viewRect = tester.getRect(mainList);

    final Finder cell = find.byKey(demo.cellKey(0, 0));
    final Rect originalRect = tester.getRect(cell);

    const double dy = 30;
    await _doScroll(tester, mainList, Offset(0, dy));

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
    expect(info.size, originalRect.size);

    final expectedVisibleBounds = Rect.fromLTRB(
        0,
        dy - (originalRect.top - viewRect.top),
        originalRect.width,
        originalRect.height);
    expect(info.visibleBounds, expectedVisibleBounds);
    expect(
        info.visibleFraction, info.visibleBounds.height / originalRect.height);
  });

  _wrapTest('VisibilityDetector horizontally scrolled partially offscreen',
      (tester) async {
    final Finder mainList = find.byKey(demo.mainListKey);
    final Rect viewRect = tester.getRect(mainList);

    final Finder cell = find.byKey(demo.cellKey(2, 0));
    expect(cell, findsOneWidget);
    final Rect originalRect = tester.getRect(cell);

    const double dx = 30;
    expect(dx < originalRect.width, true);

    await _doScroll(tester, cell, Offset(dx, 0));

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(2, 0)];
    expect(info.size, originalRect.size);

    final expectedVisibleBounds = Rect.fromLTRB(
        dx - (originalRect.left - viewRect.left),
        0,
        originalRect.width,
        originalRect.height);
    expect(info.visibleBounds, expectedVisibleBounds);
    expect(info.visibleFraction, info.visibleBounds.width / originalRect.width);
  });

  _wrapTest('VisibilityDetector scrolled fully offscreen', (tester) async {
    final Finder mainList = find.byKey(demo.mainListKey);
    expect(mainList, findsOneWidget);
    final Rect viewRect = tester.getRect(mainList);

    final Finder cell = find.byKey(demo.cellKey(0, 0));
    final Rect originalRect = tester.getRect(cell);

    final double dy = originalRect.bottom - viewRect.top;
    await _doScroll(tester, mainList, Offset(0, dy));

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
    expect(info.size, originalRect.size);
    expect(info.visibleBounds.size, Size.zero);
    expect(info.visibleFraction, 0.0);
  });

  _wrapTest('VisibilityDetector scrolled almost fully offscreen',
      (tester) async {
    final Finder mainList = find.byKey(demo.mainListKey);
    expect(mainList, findsOneWidget);
    final Rect viewRect = tester.getRect(mainList);

    final Finder cell = find.byKey(demo.cellKey(0, 0));
    final Rect originalRect = tester.getRect(cell);

    final double dy = (originalRect.bottom - viewRect.top) - 1;
    await _doScroll(tester, mainList, Offset(0, dy));

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
    expect(info.size, originalRect.size);

    final expectedVisibleBounds = Rect.fromLTRB(
        0, originalRect.height - 1, originalRect.width, originalRect.height);
    expect(info.visibleBounds, expectedVisibleBounds);
    expect(
        info.visibleFraction, info.visibleBounds.height / originalRect.height);
  });

  _wrapTest('VisibilityDetector hidden', (tester) async {
    final Finder cell = find.byKey(demo.cellKey(0, 0));
    final Rect originalRect = tester.getRect(cell);

    await _clearWidgetTree(tester, notifyNow: false);

    final VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
    expect(info.size, originalRect.size);
    expect(info.visibleBounds.size, Size.zero);
    expect(info.visibleFraction, 0.0);
  });
}

/// Initializes the widget tree that is populated with [VisibilityDetector]
/// widgets and waits sufficiently long for their visibility callbacks to fire.
Future<void> _initWidgetTree(WidgetTester tester) async {
  expect(_positionToVisibilityInfo.isEmpty, true);
  await tester.pumpWidget(demo.VisibilityDetectorDemo());

  final controller = VisibilityDetectorController.instance;
  await tester.pumpAndSettle(controller.updateInterval);
}

/// Replaces the widget tree with a [Placeholder] widget.  If `notifyNow` is
/// `true`, fires [VisibilityDetector] callbacks immediately.  Otherwise waits
/// sufficiently long for them to fire as normal.
Future<void> _clearWidgetTree(WidgetTester tester,
    {bool notifyNow = true}) async {
  await tester.pumpWidget(Placeholder());

  final controller = VisibilityDetectorController.instance;
  if (notifyNow) {
    controller.notifyNow();
  } else {
    await tester.pumpAndSettle(controller.updateInterval);
  }
}

/// Wrapper around [testWidgets] to automatically do our own custom test
/// setup and teardown.
void _wrapTest(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    // We can't use [setUp] and [tearDown] because we want access to the
    // [WidgetTester].  Additionally, [tearDown] is executed *after* the
    // widget tree is destroyed, which is too late for our purposes. (See
    // details below.)
    await _initWidgetTree(tester);
    await callback(tester);

    /// When the test destroys the widget tree with [VisibilityDetector] widgets
    /// in it, they will schedule callbacks to indicate that they've become
    /// non-visible.  The flutter_test framework then will fail assertions that
    /// there are no outstanding [Timer] objects.
    ///
    /// There currently is no direct way to suppress those assertions nor to
    /// flush those [Timer] objects. (See https://github.com/flutter/flutter/issues/24166.)
    /// Instead we must explicitly clear the widget tree ourselves and wait for
    /// callbacks to fire before ending the test.
    await _clearWidgetTree(tester);
  });
}

/// Scrolls the specified widget in the specified direction and waits
/// sufficiently long for the [VisibilityDetector] callbacks to fire.
///
/// Note that the scroll direction is the opposite of the direction to drag.
Future<void> _doScroll(
    WidgetTester tester, Finder finder, Offset scrollOffset) async {
  await tester.drag(finder, -scrollOffset);

  // Wait for the drag to complete.
  await tester.pumpAndSettle();

  // Wait for callbacks to fire.
  await tester.pump(VisibilityDetectorController.instance.updateInterval);
}
