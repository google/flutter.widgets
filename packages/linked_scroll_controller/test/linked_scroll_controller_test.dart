// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

/// This test sets up two linked, side-by-side [ListView]s, one with letter
/// captions and one with number captions, and verifies that they stay in sync
/// while scrolling.
void main() {
  group(LinkedScrollControllerGroup, () {
    testWidgets('letters drive numbers - fling', (tester) async {
      await tester.pumpWidget(Test());
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.fling(
          find.text('Hello A'), const Offset(0.0, -50.0), 10000.0);
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsNothing);
      expect(find.text('Hello 1'), findsNothing);
      expect(find.text('Hello E'), findsOneWidget);
      expect(find.text('Hello 5'), findsOneWidget);
      await tester.fling(
          find.text('Hello E'), const Offset(0.0, 50.0), 10000.0);
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
    });

    testWidgets('letters drive numbers - drag', (tester) async {
      await tester.pumpWidget(Test());
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsNothing);
      expect(find.text('Hello 4'), findsNothing);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.drag(find.text('Hello B'), const Offset(0.0, -300.0));
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsNothing);
      expect(find.text('Hello 1'), findsNothing);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsOneWidget);
      expect(find.text('Hello 4'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.drag(find.text('Hello B'), const Offset(0.0, 300.0));
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsNothing);
      expect(find.text('Hello 4'), findsNothing);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
    });

    testWidgets('numbers drive letters - fling', (tester) async {
      await tester.pumpWidget(Test());
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.fling(
          find.text('Hello 1'), const Offset(0.0, -50.0), 10000.0);
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsNothing);
      expect(find.text('Hello 1'), findsNothing);
      expect(find.text('Hello E'), findsOneWidget);
      expect(find.text('Hello 5'), findsOneWidget);
      await tester.fling(
          find.text('Hello 5'), const Offset(0.0, 50.0), 10000.0);
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
    });

    testWidgets('numbers drive letters - drag', (tester) async {
      await tester.pumpWidget(Test());
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsNothing);
      expect(find.text('Hello 4'), findsNothing);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.drag(find.text('Hello 2'), const Offset(0.0, -300.0));
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsNothing);
      expect(find.text('Hello 1'), findsNothing);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsOneWidget);
      expect(find.text('Hello 4'), findsOneWidget);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
      await tester.drag(find.text('Hello 2'), const Offset(0.0, 300.0));
      await tester.pumpAndSettle();
      expect(find.text('Hello A'), findsOneWidget);
      expect(find.text('Hello 1'), findsOneWidget);
      expect(find.text('Hello B'), findsOneWidget);
      expect(find.text('Hello 2'), findsOneWidget);
      expect(find.text('Hello C'), findsOneWidget);
      expect(find.text('Hello 3'), findsOneWidget);
      expect(find.text('Hello D'), findsNothing);
      expect(find.text('Hello 4'), findsNothing);
      expect(find.text('Hello E'), findsNothing);
      expect(find.text('Hello 5'), findsNothing);
    });

    testWidgets('offset throws for empty group', (tester) async {
      await tester.pumpWidget(TestEmptyGroup());

      final state =
          tester.state<TestEmptyGroupState>(find.byType(TestEmptyGroup));
      expect(() {
        state._controllers.offset;
      }, throwsAssertionError);
    });

    testWidgets('offset returns current position', (tester) async {
      await tester.pumpWidget(Test());

      final state = tester.state<TestState>(find.byType(Test));
      expect(state._controllers.offset, equals(0.0));

      await tester.drag(find.text('Hello 2'), const Offset(0.0, -300.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(300.0));
      expect(state._controllers.offset, equals(state._letters.offset));

      await tester.drag(find.text('Hello 2'), const Offset(0.0, 300.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(0.0));
      expect(state._controllers.offset, equals(state._letters.offset));
    });

    testWidgets('onOffsetChanged fires on scroll', (tester) async {
      await tester.pumpWidget(Test());
      final state = tester.state<TestState>(find.byType(Test));

      var onOffsetChangedCount = 0;
      void listener() {
        onOffsetChangedCount++;
      }

      state._controllers.addOffsetChangedListener(listener);

      expect(state._controllers.offset, equals(0.0));
      expect(onOffsetChangedCount, equals(0));

      await tester.drag(find.text('Hello 2'), const Offset(0.0, -1.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(1.0));
      // The count should be incremented since the scroll offset changed.
      expect(onOffsetChangedCount, equals(1));

      await tester.drag(find.text('Hello 2'), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(1.0));
      // The count should be unchanged since the scroll offset is unchanged.
      expect(onOffsetChangedCount, equals(1));

      await tester.drag(find.text('Hello 2'), const Offset(0.0, -1.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(2.0));
      // The count should be incremented since the scroll offset changed.
      expect(onOffsetChangedCount, equals(2));

      state._controllers.removeOffsetChangedListener(listener);

      await tester.drag(find.text('Hello 2'), const Offset(0.0, -1.0));
      await tester.pumpAndSettle();
      expect(state._controllers.offset, equals(3.0));
      // The count should be unchanged since we removed the listener.
      expect(onOffsetChangedCount, equals(2));
    });

    testWidgets('jumpTo jumps group to offset', (tester) async {
      await tester.pumpWidget(Test());

      final state = tester.state<TestState>(find.byType(Test));
      expect(state._controllers.offset, equals(0.0));
      expect(state._letters.position.pixels, equals(0.0));
      expect(state._numbers.position.pixels, equals(0.0));

      state._controllers.jumpTo(50.0);

      expect(state._controllers.offset, equals(50.0));
      expect(state._letters.position.pixels, equals(50.0));
      expect(state._numbers.position.pixels, equals(50.0));
    });

    testWidgets('animateTo animates group to offset', (tester) async {
      await tester.pumpWidget(Test());

      final state = tester.state<TestState>(find.byType(Test));
      expect(state._controllers.offset, equals(0.0));
      expect(state._letters.position.pixels, equals(0.0));
      expect(state._numbers.position.pixels, equals(0.0));

      // The call to `animateTo` needs to be unawaited because the animation is
      // handled by a [DrivenScrollActivity], which only completes when the
      // scroll activity is disposed.
      unawaited(state._controllers.animateTo(
        50.0,
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 200),
      ));
      await tester.pumpAndSettle();

      expect(state._controllers.offset, equals(50.0));
      expect(state._letters.position.pixels, equals(50.0));
      expect(state._numbers.position.pixels, equals(50.0));
    });

    testWidgets('resetScroll moves scroll back to 0', (tester) async {
      await tester.pumpWidget(Test());

      await tester.drag(find.text('Hello 2'), const Offset(0.0, -300.0));
      await tester.pumpAndSettle();

      final state = tester.state<TestState>(find.byType(Test));
      state._controllers.resetScroll();

      expect(state._letters.position.pixels, 0.0);
      expect(state._numbers.position.pixels, 0.0);
    });

    testWidgets('jumpTo is synced', (tester) async {
      await tester.pumpWidget(Test());
      final state = tester.state<TestState>(find.byType(Test));

      expect(state._letters.position.pixels, 0.0);
      expect(state._numbers.position.pixels, 0.0);

      state._letters.jumpTo(100.0);

      await tester.pumpAndSettle();

      expect(state._letters.position.pixels, 100.0);
      expect(state._numbers.position.pixels, 100.0);
    });

    testWidgets('tap on another scrollable during fling stops scrolling',
        (tester) async {
      await tester.pumpWidget(Test());
      final state = tester.state<TestState>(find.byType(Test));

      await tester.fling(find.text('Hello A'), const Offset(0.0, -50.0), 500.0);
      await tester.tap(find.text('Hello 1'));

      await tester.pumpAndSettle();

      // Position would be about 100 if the scroll were not stopped by the tap.
      expect(state._letters.position.pixels, 50.0);
      expect(state._numbers.position.pixels, 50.0);
    });

    testWidgets('check position after tile is remounted', (tester) async {
      await tester.pumpWidget(RemountTest());

      await tester.fling(
          find.text('ListView-A 1'), const Offset(0.0, -1000.0), 1000.0);
      await tester.pumpAndSettle();

      // ListView-A has been unmounted.
      await tester.fling(
          find.text('ListView-D 1'), const Offset(-50.0, 0.0), 500.0);
      await tester.pumpAndSettle();

      // ListView-A will be mounted.
      await tester.fling(
          find.text('ListView-D 2'), const Offset(0.0, 1000.0), 1000.0);
      await tester.pumpAndSettle();

      final state = tester.state<_RemountTestState>(find.byType(RemountTest));
      final offset = state._controllers.offset;

      tester.allStates.where((state) {
        return (state is ScrollableState) &&
            (state.widget.axis == Axis.horizontal);
      }).forEach((state) {
        final pixels = (state as ScrollableState).position.pixels;
        expect(pixels, equals(offset));
      });
    });
  });
}

class TestEmptyGroup extends StatefulWidget {
  @override
  TestEmptyGroupState createState() => TestEmptyGroupState();
}

class TestEmptyGroupState extends State<TestEmptyGroup> {
  LinkedScrollControllerGroup _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class Test extends StatefulWidget {
  @override
  TestState createState() => TestState();
}

class TestState extends State<Test> {
  LinkedScrollControllerGroup _controllers;
  ScrollController _letters;
  ScrollController _numbers;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _letters = _controllers.addAndGet();
    _numbers = _controllers.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _letters,
              children: <Widget>[
                Tile('Hello A'),
                Tile('Hello B'),
                Tile('Hello C'),
                Tile('Hello D'),
                Tile('Hello E'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _numbers,
              children: <Widget>[
                Tile('Hello 1'),
                Tile('Hello 2'),
                Tile('Hello 3'),
                Tile('Hello 4'),
                Tile('Hello 5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RemountTest extends StatefulWidget {
  @override
  _RemountTestState createState() => _RemountTestState();
}

class _RemountTestState extends State<RemountTest> {
  LinkedScrollControllerGroup _controllers;

  ScrollController _controllerA;
  ScrollController _controllerB;
  ScrollController _controllerC;
  ScrollController _controllerD;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _controllerA = _controllers.addAndGet();
    _controllerB = _controllers.addAndGet();
    _controllerC = _controllers.addAndGet();
    _controllerD = _controllers.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    final height = 400.0;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _controllerA,
              children: [
                Tile('ListView-A 1'),
                Tile('ListView-A 2'),
                Tile('ListView-A 3'),
                Tile('ListView-A 4'),
                Tile('ListView-A 5'),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _controllerB,
              children: [
                Tile('ListView-B 1'),
                Tile('ListView-B 2'),
                Tile('ListView-B 3'),
                Tile('ListView-B 4'),
                Tile('ListView-B 5'),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _controllerC,
              children: [
                Tile('ListView-C 1'),
                Tile('ListView-C 2'),
                Tile('ListView-C 3'),
                Tile('ListView-C 4'),
                Tile('ListView-C 5'),
              ],
            ),
          ),
          SizedBox(
            height: height,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _controllerD,
              children: [
                Tile('ListView-D 1'),
                Tile('ListView-D 2'),
                Tile('ListView-D 3'),
                Tile('ListView-D 4'),
                Tile('ListView-D 5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final String caption;

  Tile(this.caption);

  @override
  Widget build(_) => Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        height: 250.0,
        child: Center(child: Text(caption)),
      );
}
