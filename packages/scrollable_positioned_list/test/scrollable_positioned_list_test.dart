// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrollable_positioned_list/src/scroll_view.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const defaultItemCount = 500;
const scrollDuration = Duration(seconds: 1);
const scrollDurationTolerance = Duration(milliseconds: 1);
const tolerance = 1e-3;

void main() {
  Future<void> setUpWidgetTest(
    WidgetTester tester, {
    Key? key,
    ItemScrollController? itemScrollController,
    ItemPositionsListener? itemPositionsListener,
    int initialIndex = 0,
    double initialAlignment = 0.0,
    int itemCount = defaultItemCount,
    ScrollPhysics? physics,
    bool addSemanticIndexes = true,
    int? semanticChildCount,
    EdgeInsets? padding,
    bool addRepaintBoundaries = true,
    bool addAutomaticKeepAlives = true,
    double? minCacheExtent,
    bool variableHeight = false,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.builder(
          key: key,
          itemCount: itemCount,
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) {
            assert(index >= 0 && index <= itemCount - 1);
            return SizedBox(
              height:
                  variableHeight ? (itemHeight + (index % 13) * 5) : itemHeight,
              child: Text('Item $index'),
            );
          },
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: initialIndex,
          initialAlignment: initialAlignment,
          physics: physics,
          addSemanticIndexes: addSemanticIndexes,
          semanticChildCount: semanticChildCount,
          padding: padding,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          minCacheExtent: minCacheExtent,
        ),
      ),
    );
  }

  final Finder fadeTransitionFinder = find.descendant(
    of: find.byType(ScrollablePositionedList),
    matching: find.byType(FadeTransition),
  );

  testWidgets('List positioned with 0 at top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester, itemPositionsListener: itemPositionsListener);

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 10),
        isEmpty);
  });

  testWidgets('List positioned with 0 at top - use default values',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.builder(
          itemCount: defaultItemCount,
          itemBuilder: (context, index) => SizedBox(
            height: itemHeight,
            child: Text('Item $index'),
          ),
          itemPositionsListener: itemPositionsListener,
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 5 at top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener, initialIndex: 5);

    expect(find.text('Item 4'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);

    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 4),
        isEmpty);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);
  });

  testWidgets('List positioned with 9 at middle', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener,
        initialIndex: 9,
        initialAlignment: 0.5);

    expect(tester.getTopLeft(find.text('Item 9')).dy, screenHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        0.5);
  });

  testWidgets('List positioned with 9 half way off top',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener,
        initialIndex: 9,
        initialAlignment: -(itemHeight / screenHeight) / 2);

    expect(tester.getTopLeft(find.text('Item 9')).dy, -itemHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets('Scroll to 9 half way off top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();
    expect(itemScrollController.isAttached, false);
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener,
        itemScrollController: itemScrollController);
    expect(itemScrollController.isAttached, true);

    unawaited(itemScrollController.scrollTo(
        index: 9,
        duration: scrollDuration,
        alignment: -(itemHeight / screenHeight) / 2));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 9')).dy, -itemHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets('Jump to 9 half way off top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener,
        itemScrollController: itemScrollController);

    itemScrollController.jumpTo(
        index: 9, alignment: -(itemHeight / screenHeight) / 2);
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 9')).dy, -itemHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets('List positioned with 9 at middle scroll to 15 at bottom',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        initialIndex: 9,
        initialAlignment: 0.5);

    unawaited(itemScrollController.scrollTo(
        index: 16, duration: scrollDuration, alignment: 1.0));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getBottomRight(find.text('Item 15')).dy, screenHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 15)
            .itemTrailingEdge,
        1.0);
  });

  testWidgets('Scroll to 1 (already on screen)', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 1, duration: scrollDuration));
    await tester.pump();

    await tester.pump(scrollDuration ~/ 2);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 10'), findsOneWidget);

    await tester.pump(scrollDuration ~/ 2);
    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 10'), findsOneWidget);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 1)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 10)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 11),
        isEmpty);
  });

  testWidgets('Scroll to 1 then 2 (both already on screen)',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 1, duration: scrollDuration));
    await tester.pump();
    await tester.pump(scrollDuration);
    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 1'), findsOneWidget);

    unawaited(
        itemScrollController.scrollTo(index: 2, duration: scrollDuration));
    await tester.pump();
    await tester.pump(scrollDuration);

    expect(find.text('Item 1'), findsNothing);
    expect(find.text('Item 2'), findsOneWidget);

    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 1),
        isEmpty);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 11)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Scroll to 5 (already on screen) and then back to 0',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 5, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.text('Item 10'), findsNothing);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Scroll to 20 without fading', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    var fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    final initialOpacity = fadeTransition.opacity;

    unawaited(
        itemScrollController.scrollTo(index: 20, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity, initialOpacity);

    await tester.pumpAndSettle();

    expect(find.text('Item 14'), findsNothing);
    expect(find.text('Item 20'), findsOneWidget);
  });

  testWidgets('Scroll to 100 (not already on screen)',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(find.text('Item 99'), findsNothing);
    expect(find.text('Item 100'), findsOneWidget);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 109)
            .itemTrailingEdge,
        1);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 (not already on screen) front scroll view',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    expect(fadeTransitionFinder.evaluate().length, 2);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(0, 0.01),
    );

    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 19')).dy, screenHeight);
    expect(fadeTransitionFinder.evaluate().length, 2);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(0.5, 0.01),
    );

    await tester.pump(scrollDuration ~/ 2 - scrollDurationTolerance);
    expect(fadeTransitionFinder.evaluate().length, 2);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(1, 0.01),
    );

    await tester.pumpAndSettle();

    expect(fadeTransitionFinder.evaluate().length, 1);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(1, 0.01),
    );
  });

  testWidgets('Scroll to 100 (not already on screen) back scroll view',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);

    await tester.pumpAndSettle();
    expect(find.text('Item 25', skipOffstage: false), findsNothing);
  });

  testWidgets('Scroll to 100 (not already on screen) then back to 0',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);
    expect(find.text('Item 0'), findsNothing);

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(0, 0.01),
    );
    await tester.pump(scrollDuration + scrollDurationTolerance);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(1, 0.01),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Scroll to 100 then back to 0 back scroll view',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 90')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 then back to 0 front scroll view',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 19')).dy, screenHeight);
    expect(
      tester.widget<FadeTransition>(fadeTransitionFinder.last).opacity.value,
      closeTo(0.5, 0.01),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll 100-0-100', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 19')).dy, screenHeight);

    await tester.pumpAndSettle();
  });

  testWidgets('Jump to 100', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 100);
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 109')).dy, screenHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 109)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Jump to 100 and position at bottom',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 100, alignment: 1.0);
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 99)
            .itemTrailingEdge,
        1.0);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 100),
        isEmpty);
  });

  testWidgets('Jump to 100 and position at middle',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 100, alignment: 0.5);
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 100')).dy, screenHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0.5);
  });

  testWidgets('Manually scroll a significant distance, jump to 100',
      (WidgetTester tester) async {
    // Test for https://github.com/google/flutter.widgets/issues/144.
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        variableHeight: true);

    final listFinder = find.byType(ScrollablePositionedList);
    for (var i = 0; i < 5; i += 1) {
      await tester.drag(listFinder, const Offset(0, -screenHeight));
      await tester.pumpAndSettle();
    }

    itemScrollController.jumpTo(index: 100);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);
  }, skip: true);

  testWidgets('Scroll to 100 and position at bottom',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(itemScrollController.scrollTo(
        index: 100, alignment: 1.0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 99)
            .itemTrailingEdge,
        1.0);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 100),
        isEmpty);
  });

  testWidgets('Scroll to 100 and position at middle',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(itemScrollController.scrollTo(
        index: 100, alignment: 0.5, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 100')).dy, screenHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0.5);
  });

  testWidgets('Scroll to 9 and position at middle',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(itemScrollController.scrollTo(
        index: 9, alignment: 0.5, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 9')).dy, screenHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        0.5);
  });

  testWidgets('Scroll up a little then jump to 100',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -10));
    await tester.pumpAndSettle();

    itemScrollController.jumpTo(index: 100);
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 109')).dy, screenHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 109)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Scroll to 100 Jump to 0 Scroll to 100',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    itemScrollController.jumpTo(index: 0);
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration + scrollDurationTolerance);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 19')).dy, screenHeight);

    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 109')).dy, screenHeight);
  });

  testWidgets('Scroll to 100 stop before half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2 - scrollDuration ~/ 20);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 9')).dy, 0);
    final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity.value, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 stop half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity.value, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop before half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2 - scrollDuration ~/ 20);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 91')).dy, 0);
    expect(fadeTransitionFinder, findsNWidgets(1));

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 stop after half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2 + scrollDuration ~/ 20);

    expect(find.text('Item 9', skipOffstage: false), findsOneWidget);
    expect(tester.getBottomLeft(find.text('Item 100')).dy,
        closeTo(screenHeight, tolerance));

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getBottomLeft(find.text('Item 100')).dy,
        closeTo(screenHeight, tolerance));
    expect(find.text('Item 9', skipOffstage: false), findsNothing);
    expect(fadeTransitionFinder, findsNWidgets(1));

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop after half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2 + scrollDuration ~/ 20);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 9')).dy, closeTo(0, tolerance));
    final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity.value, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 90')).dy, 0);
    expect(fadeTransitionFinder, findsNWidgets(1));

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 jump to 250 half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    itemScrollController.jumpTo(index: 250);
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 250')).dy, 0);

    expect(find.text('Item 100'), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 250, scroll to 100, jump to 0 half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 250, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    itemScrollController.jumpTo(index: 0);
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
    expect(find.text('Item 100'), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 scroll to 250 half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    unawaited(
        itemScrollController.scrollTo(index: 250, duration: scrollDuration));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Item 250')).dy, 0);
    expect(find.text('Item 100'), findsNothing);
  });

  testWidgets('Scroll to 250, scroll to 100, scroll to 0 half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 250, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
    expect(find.text('Item 100'), findsNothing);
  });

  testWidgets(
      'Scroll to 100, scroll to 200, then scroll to 300 without waiting',
      (WidgetTester tester) async {
    // Possibly https://github.com/google/flutter.widgets/issues/171.
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    unawaited(
        itemScrollController.scrollTo(index: 200, duration: scrollDuration));
    unawaited(
        itemScrollController.scrollTo(index: 300, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsNothing);
    expect(find.text('Item 200'), findsNothing);

    var itemFinder = find.text('Item 300');
    expect(itemFinder, findsOneWidget);
    expect(tester.getTopLeft(itemFinder).dy, 0);
  }, skip: true);

  testWidgets(
      'Jump to 400 at bottom, manually scroll, scroll to 100 at bottom and back',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 400, alignment: 1);
    await tester.pumpAndSettle();

    final listFinder = find.byType(ScrollablePositionedList);

    await tester.drag(listFinder, const Offset(0, -screenHeight));
    await tester.pumpAndSettle();

    unawaited(itemScrollController.scrollTo(
        index: 100, alignment: 1, duration: scrollDuration));
    await tester.pumpAndSettle();

    unawaited(itemScrollController.scrollTo(
        index: 400, alignment: 1, duration: scrollDuration));
    await tester.pumpAndSettle();

    var itemFinder = find.text('Item 399');
    expect(itemFinder, findsOneWidget);
    expect(tester.getBottomLeft(itemFinder).dy, screenHeight);
  });

  testWidgets('physics', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        physics: const BouncingScrollPhysics());

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 50));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(find.text('Item 0')).dy, greaterThan(0));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: 0);
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 50));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(find.text('Item 0')).dy, greaterThan(0));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
  });

  testWidgets('correct index sematics', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController, initialIndex: 5);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 2 * itemHeight));
    await tester.pumpAndSettle();

    final indexSemantics3 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 3'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics3.index, 3);
    final indexSemantics4 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 4'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics4.index, 4);
    final indexSemantics5 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 5'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics5.index, 5);
    final indexSemantics6 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 6'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics6.index, 6);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: 0);
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 2 * itemHeight));
    await tester.pumpAndSettle();

    final indexSemantics3b = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 3'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics3b.index, 3);
    final indexSemantics4b = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 4'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics4b.index, 4);
    final indexSemantics5b = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 5'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics5b.index, 5);
    final indexSemantics6b = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 6'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics6b.index, 6);
  });

  testWidgets('addIndexSemantics = false', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      initialIndex: 5,
      addSemanticIndexes: false,
    );

    expect(find.byType(IndexedSemantics), findsNothing);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: 0);
    await tester.pumpAndSettle();

    expect(find.byType(IndexedSemantics), findsNothing);
  });

  testWidgets('semanticChildCount specified', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();

    await setUpWidgetTest(
      tester,
      semanticChildCount: 30,
      itemScrollController: itemScrollController,
    );

    final customScrollView =
        tester.widget<CustomScrollView>(find.byType(UnboundedCustomScrollView));
    expect(customScrollView.semanticChildCount, 30);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    final customScrollView2 =
        tester.widget<CustomScrollView>(find.byType(UnboundedCustomScrollView));
    expect(customScrollView2.semanticChildCount, 30);
  });

  testWidgets('semanticChildCount not specified', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
    );

    final customScrollView =
        tester.widget<CustomScrollView>(find.byType(UnboundedCustomScrollView));
    expect(customScrollView.semanticChildCount, defaultItemCount);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    final customScrollView2 =
        tester.widget<CustomScrollView>(find.byType(UnboundedCustomScrollView));
    expect(customScrollView2.semanticChildCount, defaultItemCount);
  });

  testWidgets('Semantic tree contains items in cache',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester, itemPositionsListener: itemPositionsListener);

    final root = WidgetsBinding
        .instance.pipelineOwner.semanticsOwner!.rootSemanticsNode!;

    final semanticNodes = <SemanticsNode>[root];

    collectSemanticNodes(root, semanticNodes);

    expect(semanticNodes.where((element) => element.label == 'Item 10'),
        isNotEmpty);
  });

  testWidgets('padding test - centered at top', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 1')),
        const Offset(10, 10 + itemHeight));
    expect(tester.getTopRight(find.text('Item 1')),
        const Offset(screenWidth - 10, 10 + itemHeight));

    unawaited(
        itemScrollController.scrollTo(index: 490, duration: scrollDuration));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(find.text('Item 499')),
        const Offset(screenWidth - 10, screenHeight - 10));
  });

  testWidgets('padding test - centered not at top',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      initialIndex: 2,
      padding: const EdgeInsets.all(10),
    );

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 200));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 2')),
        const Offset(10, 10 + 2 * itemHeight));
    expect(tester.getTopLeft(find.text('Item 3')),
        const Offset(10, 10 + 3 * itemHeight));
  });

  testWidgets('padding - first element centered - scroll up',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 100));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
  });

  testWidgets('padding - last element centered - scroll down',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    unawaited(itemScrollController.scrollTo(
        index: defaultItemCount - 1, duration: scrollDuration));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(
      tester.getBottomLeft(find.text('Item ${defaultItemCount - 1}')),
      const Offset(10, screenHeight - 10),
    );
  });

  testWidgets('no repaint boundaries', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      initialIndex: 2,
      padding: const EdgeInsets.all(10),
      addRepaintBoundaries: false,
    );

    expect(
        tester
            .widgetList(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(RepaintBoundary)))
            .length,
        lessThan(5));
  });

  testWidgets('no automatic keep alives', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      initialIndex: 2,
      padding: const EdgeInsets.all(10),
      addAutomaticKeepAlives: false,
    );

    expect(
        find.descendant(
            of: find.byType(ScrollablePositionedList),
            matching: find.byType(AutomaticKeepAlive)),
        findsNothing);
  });

  testWidgets('Jump to end of list', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    itemScrollController.jumpTo(index: defaultItemCount - 1);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.text('Item ${defaultItemCount - 1}')).dy,
        screenHeight);
  });

  testWidgets('Scroll to end of list', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(itemScrollController.scrollTo(
        index: defaultItemCount - 1, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.text('Item ${defaultItemCount - 1}')).dy,
        screenHeight);
  });

  testWidgets('Scroll to end of list, jump to beginning, jump to end',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    unawaited(itemScrollController.scrollTo(
        index: defaultItemCount - 1, duration: scrollDuration));
    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: 0);
    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: defaultItemCount - 1);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.text('Item ${defaultItemCount - 1}')).dy,
        screenHeight);
  });

  testWidgets('Jump to end of list, scroll to beginning, scroll to end',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    itemScrollController.jumpTo(index: defaultItemCount - 1);
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pumpAndSettle();
    unawaited(itemScrollController.scrollTo(
        index: defaultItemCount - 1, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.text('Item ${defaultItemCount - 1}')).dy,
        screenHeight);
  });

  testWidgets(
      'Jump to end of list, jump to beginning with alignment not at top',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester, itemScrollController: itemScrollController);

    itemScrollController.jumpTo(index: defaultItemCount - 1);
    await tester.pumpAndSettle();

    itemScrollController.jumpTo(index: 0, alignment: 0.3);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
  });

  testWidgets("Short list, can't scroll past end", (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController, itemCount: 3);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -10));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
  });

  testWidgets('List can be keyed', (WidgetTester tester) async {
    final key = ValueKey('key');

    await setUpWidgetTest(tester, key: key);

    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets(
      'Maintain programmatic position (9 half way off top) in page view',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();

    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: PageView(
          children: [
            KeyedSubtree(
              key: PageStorageKey('key'),
              child: ScrollablePositionedList.builder(
                itemCount: defaultItemCount,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) => SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                ),
                itemPositionsListener: itemPositionsListener,
              ),
            ),
            Center(
              child: Text('Test'),
            )
          ],
        ),
      ),
    );

    itemScrollController.jumpTo(
        index: 9, alignment: -(itemHeight / screenHeight) / 2);
    await tester.pump();

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 9')).dy, -itemHeight / 2);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets('Maintain user scroll position (1 half way off top) in page view',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();

    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: PageView(
          children: [
            KeyedSubtree(
              key: PageStorageKey('key'),
              child: ScrollablePositionedList.builder(
                itemCount: defaultItemCount,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) => SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                ),
                itemPositionsListener: itemPositionsListener,
              ),
            ),
            Center(
              child: Text('Test'),
            )
          ],
        ),
      ),
    );

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -itemHeight));
    await tester.pumpAndSettle();

    final item0Bottom = tester.getBottomRight(find.text('Item 0')).dy;
    expect(item0Bottom, lessThan(itemHeight));

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(find.text('Item 0')).dy, item0Bottom);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets(
      'Maintain programmatic and user position (9 half way off top) in page view',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();

    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: PageView(
          children: [
            KeyedSubtree(
              key: PageStorageKey('key'),
              child: ScrollablePositionedList.builder(
                itemCount: defaultItemCount,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) => SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                ),
                itemPositionsListener: itemPositionsListener,
              ),
            ),
            Center(
              child: Text('Test'),
            )
          ],
        ),
      ),
    );

    itemScrollController.jumpTo(index: 9);
    await tester.pump();

    expect(tester.getBottomRight(find.text('Item 9')).dy, itemHeight);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -itemHeight));
    await tester.pumpAndSettle();

    final item9Bottom = tester.getBottomRight(find.text('Item 9')).dy;
    expect(item9Bottom, lessThan(itemHeight));

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(find.text('Item 9')).dy, item9Bottom);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        -(itemHeight / screenHeight) / 2);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        (itemHeight / screenHeight) / 2);
  });

  testWidgets("List with no items", (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController, itemCount: 0);

    expect(find.text('Item 0'), findsNothing);
  });

  testWidgets('Jump to 100 then set itemCount to 0',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final itemCount = ValueNotifier<int>(defaultItemCount);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: itemCount,
          builder: (context, itemCount, child) {
            return ScrollablePositionedList.builder(
              initialScrollIndex: min(100, itemCount),
              initialAlignment: 0,
              itemCount: itemCount,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (context, index) {
                assert(index >= 0 && index <= itemCount - 1);
                return SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    itemScrollController.jumpTo(index: 100);
    await tester.pumpAndSettle();
    expect(find.text('Item 100'), findsOneWidget);

    itemCount.value = 0;
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Item 100'), findsNothing);
    expect(itemPositionsListener.itemPositions.value.isEmpty, isTrue);
  });

  testWidgets('List positioned with 100 at top then set itemCount to 100',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemCount = ValueNotifier<int>(defaultItemCount);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: itemCount,
          builder: (context, itemCount, child) {
            return ScrollablePositionedList.builder(
              initialScrollIndex: min(100, itemCount - 1),
              initialAlignment: 0,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                assert(index >= 0 && index <= itemCount - 1);
                return SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);

    itemCount.value = 100;
    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsNothing);
    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);
  });

  testWidgets('List positioned with 499 at bottom then set itemCount to 100',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemCount = ValueNotifier<int>(defaultItemCount);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: itemCount,
          builder: (context, itemCount, child) {
            return ScrollablePositionedList.builder(
              initialScrollIndex: itemCount - 1,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                assert(index >= 0 && index <= itemCount - 1);
                return SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('Item 499')).dy, screenHeight);

    itemCount.value = 100;
    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsNothing);
    expect(tester.getBottomLeft(find.text('Item 99')).dy, screenHeight);
  });

  testWidgets('Large minCacheExtent', (WidgetTester tester) async {
    await setUpWidgetTest(tester, minCacheExtent: 200 * itemHeight);

    expect(find.text('Item 100', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Scroll to 20 without fading small minCacheExtent',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      minCacheExtent: 10,
    );

    var fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    final initialOpacity = fadeTransition.opacity;

    unawaited(
        itemScrollController.scrollTo(index: 20, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity, initialOpacity);

    await tester.pumpAndSettle();

    expect(find.text('Item 14'), findsNothing);
    expect(find.text('Item 20'), findsOneWidget);
  });

  testWidgets('Scroll to 100 without fading for large minCacheExtent',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();

    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      minCacheExtent: 200 * itemHeight,
    );

    var fadeTransition = tester.widget<FadeTransition>(
      fadeTransitionFinder,
    );
    final initialOpacity = fadeTransition.opacity;

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);
    expect(fadeTransition.opacity, initialOpacity);

    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsOneWidget);
  });

  testWidgets('Position list when not enough above top item to fill viewport',
      (WidgetTester tester) async {
    const alignment = 0.8;

    await setUpWidgetTest(
      tester,
      itemCount: 2,
      initialAlignment: alignment,
      initialIndex: 0,
    );

    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')).dy, screenHeight * alignment);
  });

  testWidgets('Rebuild with scroll controller', (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);
    final key = ValueNotifier<Key>(ValueKey('key'));
    final itemScrollController = ItemScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<Key>(
          valueListenable: key,
          builder: (context, key, child) {
            return Container(
              key: key,
              child: ScrollablePositionedList.builder(
                itemCount: 200,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: itemHeight,
                    child: Text('Item $index'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    key.value = ValueKey('newKey');
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsOneWidget);
  });

  testWidgets('Double rebuild with scroll controller',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);
    final outerKey = ValueNotifier<Key>(ValueKey('outerKey'));
    final innerKey = GlobalKey();
    final listKey = ValueNotifier<Key>(ValueKey(null));
    final itemScrollController = ItemScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<Key>(
          valueListenable: outerKey,
          builder: (context, outerKey, child) => ValueListenableBuilder<Key>(
            valueListenable: listKey,
            builder: (context, listKey, child) => Container(
              key: outerKey,
              child: Builder(
                builder: (context) => Container(
                  key: innerKey,
                  child: ScrollablePositionedList.builder(
                    key: listKey,
                    itemCount: 200,
                    itemScrollController: itemScrollController,
                    itemBuilder: (context, index) => SizedBox(
                      height: itemHeight,
                      child: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    outerKey.value = ValueKey('newOuterKey');
    listKey.value = ValueKey('newListKey');
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 100'), findsOneWidget);
  });

  testWidgets('Key change with scroll controller', (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);
    final key = ValueNotifier<Key>(ValueKey('key'));
    final itemScrollController = ItemScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<Key>(
          valueListenable: key,
          builder: (context, key, child) {
            return ScrollablePositionedList.builder(
              key: key,
              itemCount: 10,
              itemScrollController: itemScrollController,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    key.value = ValueKey('newKey');
    await tester.pumpAndSettle();
  });

  testWidgets('Scroll after rebuild', (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);
    final key = ValueNotifier<Key>(ValueKey('key'));
    final itemScrollController = ItemScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<Key>(
          valueListenable: key,
          builder: (context, key, child) {
            return Container(
              key: key,
              child: ScrollablePositionedList.builder(
                itemCount: 100,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: itemHeight,
                    child: Text('Item $index'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    key.value = ValueKey('newKey');
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 70, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 70'), findsOneWidget);
  });

  testWidgets('Scroll after rebuild when resusing state',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);
    final containerKey = ValueNotifier<Key>(ValueKey('key'));
    final scrollKey = GlobalKey();
    final itemScrollController = ItemScrollController();

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<Key>(
          valueListenable: containerKey,
          builder: (context, key, child) {
            return Container(
              key: key,
              child: ScrollablePositionedList.builder(
                key: scrollKey,
                itemCount: 100,
                itemScrollController: itemScrollController,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: itemHeight,
                    child: Text('Item $index'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    containerKey.value = ValueKey('newKey');
    await tester.pumpAndSettle();

    unawaited(
        itemScrollController.scrollTo(index: 70, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 70'), findsOneWidget);
  });

  testWidgets('Scroll after changing scroll controller',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemScrollController0 = ItemScrollController();
    final itemScrollController1 = ItemScrollController();
    final itemScrollControllerListenable = ValueNotifier(itemScrollController0);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<ItemScrollController>(
          valueListenable: itemScrollControllerListenable,
          builder: (context, itemScrollController, child) {
            return ScrollablePositionedList.builder(
              itemCount: 100,
              itemScrollController: itemScrollController,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: itemHeight,
                  child: Text('Item $index'),
                );
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(itemScrollController0.isAttached, true);
    expect(itemScrollController1.isAttached, false);

    itemScrollControllerListenable.value = itemScrollController1;
    await tester.pumpAndSettle();

    expect(itemScrollController0.isAttached, false);
    expect(itemScrollController1.isAttached, true);

    unawaited(
        itemScrollController1.scrollTo(index: 70, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 70'), findsOneWidget);
  });

  testWidgets('Scroll after swapping scroll controllers',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemScrollController0 = ItemScrollController();
    final itemScrollController1 = ItemScrollController();
    final topItemScrollControllerListenable =
        ValueNotifier(itemScrollController0);
    final bottomItemScrollControllerListenable =
        ValueNotifier(itemScrollController1);

    await tester.pumpWidget(MaterialApp(
      home: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<ItemScrollController>(
              valueListenable: topItemScrollControllerListenable,
              builder: (context, itemScrollController, child) {
                return ScrollablePositionedList.builder(
                  itemCount: 100,
                  itemScrollController: itemScrollController,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: itemHeight,
                      child: Text('Item $index'),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<ItemScrollController>(
              valueListenable: bottomItemScrollControllerListenable,
              builder: (context, itemScrollController, child) {
                return ScrollablePositionedList.builder(
                  itemCount: 100,
                  itemScrollController: itemScrollController,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: itemHeight,
                      child: Text('Item $index'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ));

    await tester.pumpAndSettle();
    expect(itemScrollController0.isAttached, true);
    expect(itemScrollController1.isAttached, true);

    topItemScrollControllerListenable.value = itemScrollController1;
    bottomItemScrollControllerListenable.value = itemScrollController0;
    await tester.pumpAndSettle();

    expect(itemScrollController0.isAttached, true);
    expect(itemScrollController1.isAttached, true);

    unawaited(
        itemScrollController1.scrollTo(index: 70, duration: scrollDuration));
    unawaited(
        itemScrollController0.scrollTo(index: 50, duration: scrollDuration));
    await tester.pumpAndSettle();

    expect(find.text('Item 70'), findsOneWidget);
    expect(find.text('Item 50'), findsOneWidget);
  });
}

bool collectSemanticNodes(SemanticsNode root, List<SemanticsNode> nodes) {
  nodes.add(root);
  if (!root.hasChildren) return true;
  root.visitChildren((child) => collectSemanticNodes(child, nodes));
  return true;
}
