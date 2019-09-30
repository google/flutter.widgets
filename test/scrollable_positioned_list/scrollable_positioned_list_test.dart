// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:flutter_widgets/src/scrollable_positioned_list/scrollable_positioned_list.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const itemCount = 500;
const scrollDuration = Duration(seconds: 1);
const scrollDurationTolerance = Duration(milliseconds: 1);
const tolerance = 1e-3;

void main() {
  Future<void> setUp(
    WidgetTester tester, {
    ItemScrollController itemScrollController,
    ItemPositionsListener itemPositionsListener,
    int initialIndex = 0,
    double initialAlignment = 0.0,
    ScrollPhysics physics,
    bool addSemanticIndexes = true,
    int semanticChildCount,
    EdgeInsets padding,
    bool addRepaintBoundaries = true,
    bool addAutomaticKeepAlives = true,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.builder(
          itemCount: itemCount,
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) => SizedBox(
            height: itemHeight,
            child: Text('Item $index'),
          ),
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: initialIndex,
          initialAlignment: initialAlignment,
          physics: physics,
          addSemanticIndexes: addSemanticIndexes,
          semanticChildCount: semanticChildCount,
          padding: padding,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        ),
      ),
    );
  }

  testWidgets('List positioned with 0 at top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUp(tester, itemPositionsListener: itemPositionsListener);

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
          itemCount: itemCount,
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
    await setUp(tester,
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
    await setUp(tester,
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

  testWidgets('List positioned with 9 at middle scroll to 14 at bottom',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester,
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

  testWidgets('Scroll to 15 without fading', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUp(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    Opacity opacityWidget = tester.widget(find.descendant(
        of: find.byType(ScrollablePositionedList),
        matching: find.byType(Opacity)));
    final double initialOpacity = opacityWidget.opacity;

    unawaited(
        itemScrollController.scrollTo(index: 20, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    opacityWidget = tester.widget(find.descendant(
        of: find.byType(ScrollablePositionedList),
        matching: find.byType(Opacity)));
    expect(opacityWidget.opacity, initialOpacity);

    await tester.pumpAndSettle();

    expect(find.text('Item 14'), findsNothing);
    expect(find.text('Item 20'), findsOneWidget);
  });

  testWidgets('Scroll to 100 (not already on screen)',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUp(tester,
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
    await setUp(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    expect(
        tester
            .widget<Opacity>(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(Opacity)))
            .opacity,
        closeTo(1, 0.01));

    await tester.pump(scrollDuration ~/ 2);

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    expect(tester.getBottomLeft(find.text('Item 19')).dy, screenHeight);
    expect(
        tester
            .widget<Opacity>(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(Opacity)))
            .opacity,
        closeTo(0.5, 0.01));

    await tester.pump(scrollDuration ~/ 2);
    expect(
        tester
            .widget<Opacity>(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(Opacity)))
            .opacity,
        closeTo(0, 0.01));

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 (not already on screen) back scroll view',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester,
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
        tester
            .widget<Opacity>(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(Opacity)))
            .opacity,
        closeTo(0, 0.01));
    await tester.pump(scrollDuration + scrollDurationTolerance);
    expect(
        tester
            .widget<Opacity>(find.descendant(
                of: find.byType(ScrollablePositionedList),
                matching: find.byType(Opacity)))
            .opacity,
        closeTo(1, 0.01));

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
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester, itemScrollController: itemScrollController);

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
        tester
            .widget<Opacity>(find.ancestor(
                of: find.text('Item 10'), matching: find.byType(Opacity)))
            .opacity,
        closeTo(0.5, 0.01));

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll 100-0-100', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester,
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

  testWidgets('Scroll to 100 and position at bottom',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester,
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
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2 - scrollDuration ~/ 20);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 9')).dy, 0);
    final Opacity opacityWidget = tester.widget(find.descendant(
        of: find.byType(ScrollablePositionedList),
        matching: find.byType(Opacity)));
    expect(opacityWidget.opacity, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 stop half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pump();

    expect(tester.getTopLeft(find.text('Item 10')).dy, 0);
    final Opacity opacityWidget = tester.widget(find.descendant(
        of: find.byType(ScrollablePositionedList),
        matching: find.byType(Opacity)));
    expect(opacityWidget.opacity, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop before half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    expect(find.byType(Opacity), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 stop after half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    expect(find.byType(Opacity), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop after half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    final Opacity opacityWidget = tester.widget(find.descendant(
        of: find.byType(ScrollablePositionedList),
        matching: find.byType(Opacity)));
    expect(opacityWidget.opacity, 1.0);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 0 stop half way', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    expect(find.byType(Opacity), findsNothing);

    await tester.pumpAndSettle();
  });

  testWidgets('Scroll to 100 jump to 250 half way',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester, itemScrollController: itemScrollController);

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
    await setUp(tester, itemScrollController: itemScrollController);

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

  testWidgets('physics', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(tester,
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
    await setUp(tester,
        itemScrollController: itemScrollController, initialIndex: 5);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 2 * itemHeight));
    await tester.pumpAndSettle();

    final IndexedSemantics indexSemantics3 = tester.widget(find.ancestor(
        of: find.text('Item 3'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics3.index, 3);
    final IndexedSemantics indexSemantics4 = tester.widget(find.ancestor(
        of: find.text('Item 4'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics4.index, 4);
    final IndexedSemantics indexSemantics5 = tester.widget(find.ancestor(
        of: find.text('Item 5'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics5.index, 5);
    final IndexedSemantics indexSemantics6 = tester.widget(find.ancestor(
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

    final IndexedSemantics indexSemantics3b = tester.widget(find.ancestor(
        of: find.text('Item 3'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics3b.index, 3);
    final IndexedSemantics indexSemantics4b = tester.widget(find.ancestor(
        of: find.text('Item 4'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics4b.index, 4);
    final IndexedSemantics indexSemantics5b = tester.widget(find.ancestor(
        of: find.text('Item 5'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics5b.index, 5);
    final IndexedSemantics indexSemantics6b = tester.widget(find.ancestor(
        of: find.text('Item 6'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics6b.index, 6);
  });

  testWidgets('addIndexSemantics = false', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(
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

    await setUp(
      tester,
      semanticChildCount: 30,
      itemScrollController: itemScrollController,
    );

    final CustomScrollView customScrollView =
        tester.widget(find.byType(CustomScrollView));
    expect(customScrollView.semanticChildCount, 30);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    final CustomScrollView customScrollView2 =
        tester.widget(find.byType(CustomScrollView));
    expect(customScrollView2.semanticChildCount, 30);
  });

  testWidgets('semanticChildCount not specified', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(
      tester,
      itemScrollController: itemScrollController,
    );

    final CustomScrollView customScrollView =
        tester.widget(find.byType(CustomScrollView));
    expect(customScrollView.semanticChildCount, itemCount);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));
    await tester.pumpAndSettle();

    final CustomScrollView customScrollView2 =
        tester.widget(find.byType(CustomScrollView));
    expect(customScrollView2.semanticChildCount, itemCount);
  });

  testWidgets('padding test 1', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(
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

  testWidgets('padding test 2', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(
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

  testWidgets('no repaint bounderies', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUp(
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
    await setUp(
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
}
