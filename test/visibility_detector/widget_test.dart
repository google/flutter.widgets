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

/// [Key] used to identify the [_TestPropertyChange] widget.
final _testPropertyChangeKey = GlobalKey<_TestPropertyChangeState>();

void main() {
  demo.visibilityListeners.add((demo.RowColumn rc, VisibilityInfo info) {
    _positionToVisibilityInfo[rc] = info;
  });

  tearDown(() {
    _positionToVisibilityInfo.clear();
  });

  _wrapTest(
    'VisibilityDetector properly builds',
    callback: (tester) async {
      expect(find.byType(ErrorWidget), findsNothing);

      final Finder cell = find.byKey(demo.cellKey(0, 0));
      expect(cell, findsOneWidget);
    },
  );

  _wrapTest(
    'VisibilityDetector reports initial visibility',
    callback: (tester) async {
      final Finder cell = find.byKey(demo.cellKey(0, 0));
      final Rect expectedRect = tester.getRect(cell);

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.size, expectedRect.size);
      expect(info.size.width > 0, true);
      expect(info.size.height > 0, true);
      expect(info.size.height, demo.kRowHeight - 2 * demo.kRowPadding);
      expect(info.visibleBounds, Offset.zero & info.size);
      expect(info.visibleFraction, 1.0);
    },
  );

  _wrapTest(
    'VisibilityDetector reports partial visibility when part of it is '
        'vertically scrolled offscreen',
    callback: (tester) async {
      final Finder mainList = find.byKey(demo.mainListKey);
      expect(mainList, findsOneWidget);
      final Rect viewRect = tester.getRect(mainList);

      final Finder cell = find.byKey(demo.cellKey(0, 0));
      final Rect originalRect = tester.getRect(cell);

      const double dy = 30;
      await _doScroll(tester, mainList, Offset(0, dy));

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.size, originalRect.size);

      final expectedVisibleBounds = Rect.fromLTRB(
          0,
          dy - (originalRect.top - viewRect.top),
          originalRect.width,
          originalRect.height);
      expect(info.visibleBounds, expectedVisibleBounds);
      expect(info.visibleFraction,
          info.visibleBounds.height / originalRect.height);
    },
  );

  _wrapTest(
    'VisibilityDetector reports partial visibility when part of it is '
        'horizontally scrolled offscreen',
    callback: (tester) async {
      final Finder mainList = find.byKey(demo.mainListKey);
      final Rect viewRect = tester.getRect(mainList);

      final Finder cell = find.byKey(demo.cellKey(2, 0));
      expect(cell, findsOneWidget);
      final Rect originalRect = tester.getRect(cell);

      const double dx = 30;
      expect(dx < originalRect.width, true);

      await _doScroll(tester, cell, Offset(dx, 0));

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(2, 0)];
      expect(info.size, originalRect.size);

      final expectedVisibleBounds = Rect.fromLTRB(
          dx - (originalRect.left - viewRect.left),
          0,
          originalRect.width,
          originalRect.height);
      expect(info.visibleBounds, expectedVisibleBounds);
      expect(
          info.visibleFraction, info.visibleBounds.width / originalRect.width);
    },
  );

  _wrapTest(
    'VisibilityDetector reports being not visible when fully scrolled '
        'offscreen',
    callback: (tester) async {
      final Finder mainList = find.byKey(demo.mainListKey);
      expect(mainList, findsOneWidget);
      final Rect viewRect = tester.getRect(mainList);

      final Finder cell = find.byKey(demo.cellKey(0, 0));
      final Rect originalRect = tester.getRect(cell);

      final double dy = originalRect.bottom - viewRect.top;
      await _doScroll(tester, mainList, Offset(0, dy));

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.size, originalRect.size);
      expect(info.visibleBounds.size, Size.zero);
      expect(info.visibleFraction, 0.0);
    },
  );

  _wrapTest(
    'VisibilityDetector reports partial visibility when almost fully scrolled '
        'offscreen',
    callback: (tester) async {
      final Finder mainList = find.byKey(demo.mainListKey);
      expect(mainList, findsOneWidget);
      final Rect viewRect = tester.getRect(mainList);

      final Finder cell = find.byKey(demo.cellKey(0, 0));
      final Rect originalRect = tester.getRect(cell);

      final double dy = (originalRect.bottom - viewRect.top) - 1;
      await _doScroll(tester, mainList, Offset(0, dy));

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.size, originalRect.size);

      final expectedVisibleBounds = Rect.fromLTRB(
          0, originalRect.height - 1, originalRect.width, originalRect.height);
      expect(info.visibleBounds, expectedVisibleBounds);
      expect(info.visibleFraction,
          info.visibleBounds.height / originalRect.height);
    },
  );

  _wrapTest(
    'VisibilityDetector reports being not visible when removed from the widget '
        'tree',
    callback: (tester) async {
      final Finder cell = find.byKey(demo.cellKey(0, 0));
      final Rect originalRect = tester.getRect(cell);

      await _clearWidgetTree(tester, notifyNow: false);

      final VisibilityInfo info =
          _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.size, originalRect.size);
      expect(info.visibleBounds.size, Size.zero);
      expect(info.visibleFraction, 0.0);
    },
  );

  testWidgets(
    'VisibilityDetector callbacks fire immediately when setting '
        'updateInterval=0',
    (tester) async {
      final controller = VisibilityDetectorController.instance;
      final oldDuration = controller.updateInterval;
      addTearDown(() {
        controller.updateInterval = oldDuration;
      });
      controller.updateInterval = Duration.zero;

      await tester.pumpWidget(demo.VisibilityDetectorDemo());
      VisibilityInfo info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.visibleFraction, 1.0);

      await tester.pumpWidget(Placeholder());

      info = _positionToVisibilityInfo[demo.RowColumn(0, 0)];
      expect(info.visibleFraction, 0.0);
    },
  );

  _wrapTest(
    'VisibilityDetector fires callbacks when becoming enabled and not when '
        'becoming disabled',
    widget: _TestPropertyChange(key: _testPropertyChangeKey),
    callback: (tester) async {
      _TestPropertyChangeState state = _testPropertyChangeKey.currentState;

      // Validate the initial state.  The visibility callback should have fired
      // exactly once.
      expect(state.lastVisibleFraction, 1.0);
      expect(state.callbackCount, 1);

      // Disable the [VisibilityDetector].  This should not trigger the
      // visibility callback.
      await _doStateChange(tester, () {
        state.visibilityDetectorEnabled = false;
      });
      expect(state.lastVisibleFraction, 1.0);
      expect(state.callbackCount, 1);

      // Re-enable the [VisibilityDetector].  This should re-trigger the
      // visibility callback.
      await _doStateChange(tester, () {
        state.visibilityDetectorEnabled = true;
      });
      expect(state.lastVisibleFraction, 1.0);
      expect(state.callbackCount, 2);
    },
  );
}

/// Initializes the widget tree that is populated with [VisibilityDetector]
/// widgets and waits sufficiently long for their visibility callbacks to fire.
Future<void> _initWidgetTree(Widget widget, WidgetTester tester) async {
  expect(_positionToVisibilityInfo.isEmpty, true);
  await tester.pumpWidget(widget);

  final controller = VisibilityDetectorController.instance;
  if (controller.updateInterval != Duration.zero) {
    await tester.pumpAndSettle(controller.updateInterval);
  }
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
  } else if (controller.updateInterval != Duration.zero) {
    await tester.pumpAndSettle(controller.updateInterval);
  }
}

/// Wrapper around [testWidgets] to automatically do our own custom test
/// setup and teardown.
void _wrapTest(
  String description, {
  Widget widget,
  @required WidgetTesterCallback callback,
}) {
  testWidgets(description, (tester) async {
    // We can't use [setUp] and [tearDown] because we want access to the
    // [WidgetTester].  Additionally, [tearDown] is executed *after* the
    // widget tree is destroyed, which is too late for our purposes. (See
    // details below.)
    await _initWidgetTree(widget ?? demo.VisibilityDetectorDemo(), tester);
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

/// Invokes a callback to mutate a [State] object and waits sufficiently long
/// for the [VisibilityDetector] callbacks to fire.
Future<void> _doStateChange(WidgetTester tester, VoidCallback callback) async {
  callback();

  // Wait for the state change to rebuild the widget.
  await tester.pump();

  // Wait for callbacks to fire.
  await tester.pump(VisibilityDetectorController.instance.updateInterval);
}

/// A widget used to test that disabling a [VisibilityDetector] does not trigger
/// its visibility callback and that re-enabling it does.
class _TestPropertyChange extends StatefulWidget {
  const _TestPropertyChange({Key key}) : super(key: key);

  @override
  _TestPropertyChangeState createState() => _TestPropertyChangeState();
}

class _TestPropertyChangeState extends State<_TestPropertyChange> {
  /// Whether our [VisibilityDetector] should be enabled (i.e., whether it
  /// should fire visibility callbacks).
  bool _visibilityDetectorEnabled = true;
  bool get visibilityDetectorEnabled => _visibilityDetectorEnabled;
  set visibilityDetectorEnabled(bool value) {
    setState(() {
      _visibilityDetectorEnabled = value;
    });
  }

  /// The last reported visibility of our [VisibilityDetector].
  double _lastVisibleFraction = 0;
  double get lastVisibleFraction => _lastVisibleFraction;

  /// The number of times that our [VisibilityDetector]'s callback has been
  /// triggered.
  int _callbackCount = 0;
  int get callbackCount => _callbackCount;

  /// [VisibilityDetector] callback for when the visibility of the widget
  /// changes.
  void _handleVisibilityChanged(VisibilityInfo info) {
    _lastVisibleFraction = info.visibleFraction;
    _callbackCount += 1;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('TestPropertyChange'),
      onVisibilityChanged:
          visibilityDetectorEnabled ? _handleVisibilityChanged : null,
      child: const Placeholder(),
    );
  }
}
