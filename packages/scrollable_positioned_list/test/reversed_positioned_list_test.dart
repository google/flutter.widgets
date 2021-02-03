// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrollable_positioned_list/src/item_positions_notifier.dart';
import 'package:scrollable_positioned_list/src/positioned_list.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const defaultItemCount = 500;

void main() {
  final itemPositionsNotifier = ItemPositionsListener.create();

  Future<void> setUpWidgetTest(
    WidgetTester tester, {
    int topItem = 0,
    ScrollController? scrollController,
    double anchor = 0,
    int itemCount = defaultItemCount,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: PositionedList(
          itemCount: itemCount,
          positionedIndex: topItem,
          alignment: anchor,
          controller: scrollController,
          itemBuilder: (context, index) => SizedBox(
            height: itemHeight,
            child: Text('Item $index'),
          ),
          itemPositionsNotifier: itemPositionsNotifier as ItemPositionsNotifier,
          reverse: true,
        ),
      ),
    );
  }

  testWidgets('short list', (WidgetTester tester) async {
    await setUpWidgetTest(tester, itemCount: 5);
    await tester.pump();

    expect(tester.getBottomRight(find.text('Item 0')).dy, screenHeight);
    expect(find.text('Item 4'), findsOneWidget);
    expect(find.text('Item 5'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 4)
            .itemTrailingEdge,
        1 / 2);
  });

  testWidgets('List positioned with 0 at bottom', (WidgetTester tester) async {
    await setUpWidgetTest(tester);
    await tester.pump();

    expect(tester.getBottomRight(find.text('Item 0')).dy, screenHeight);
    expect(tester.getTopLeft(find.text('Item 9')).dy, 0);
    expect(find.text('Item 10'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 5 at bottom', (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 5);
    await tester.pump();

    expect(find.text('Item 4'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 14'), findsOneWidget);
    expect(find.text('Item 15'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 4)
            .itemLeadingEdge,
        -1 / 10);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 4)
            .itemTrailingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 14)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 15 at bottom', (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 15, anchor: 0);
    await tester.pump();

    expect(find.text('Item 14'), findsNothing);
    expect(find.text('Item 15'), findsOneWidget);
    expect(find.text('Item 24'), findsOneWidget);
    expect(find.text('Item 25'), findsNothing);
  });

  testWidgets('List positioned with 15 at top', (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 15, anchor: 1);
    await tester.pump();

    expect(find.text('Item 15'), findsNothing);
    expect(find.text('Item 14'), findsOneWidget);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 15)
            .itemLeadingEdge,
        1);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 14)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 14)
            .itemLeadingEdge,
        9 / 10);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);
  });

  testWidgets('List positioned with 5 at bottom then scroll up 2',
      (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 5);

    await tester.drag(
        find.byType(PositionedList), const Offset(0, 2 * itemHeight));
    await tester.pump();

    expect(find.text('Item 6'), findsNothing);
    expect(find.text('Item 7'), findsOneWidget);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 7)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 7)
            .itemTrailingEdge,
        1 / 10);
  });

  testWidgets('List positioned with 0 at bottom scroll to item 5',
      (WidgetTester tester) async {
    final scrollController = ScrollController();
    await setUpWidgetTest(tester, scrollController: scrollController);
    await tester.pump();

    scrollController.jumpTo(5 * itemHeight);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Item 4'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Item 14'), findsOneWidget);
    expect(find.text('Item 15'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 4)
            .itemLeadingEdge,
        -1 / 10);
  });

  testWidgets(
      'List positioned with 5 at bottom then scroll up 2 programatically',
      (WidgetTester tester) async {
    final scrollController = ScrollController();
    await setUpWidgetTest(tester,
        topItem: 5, scrollController: scrollController);

    scrollController.jumpTo(2 * itemHeight);
    await tester.pump();

    expect(find.text('Item 6'), findsNothing);
    expect(find.text('Item 7'), findsOneWidget);
    expect(find.text('Item 16'), findsOneWidget);
    expect(find.text('Item 17'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemLeadingEdge,
        -1 / 10);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 7)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 16)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 5 at bottom and initial scroll offset',
      (WidgetTester tester) async {
    final scrollController =
        ScrollController(initialScrollOffset: 2 * itemHeight);
    await setUpWidgetTest(tester,
        topItem: 5, scrollController: scrollController);

    expect(find.text('Item 6'), findsNothing);
    expect(find.text('Item 7'), findsOneWidget);
    expect(find.text('Item 16'), findsOneWidget);
    expect(find.text('Item 17'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemLeadingEdge,
        -1 / 10);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 7)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 16)
            .itemTrailingEdge,
        1);
  });
}
