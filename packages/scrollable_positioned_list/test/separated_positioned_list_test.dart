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
const separatorHeight = screenHeight / 20.0;
const defaultItemCount = 500;
const cacheExtent = itemHeight * 2;

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
          separatorBuilder: (context, index) => SizedBox(
            height: separatorHeight,
            child: Text('Separator $index'),
          ),
          itemPositionsNotifier: itemPositionsNotifier as ItemPositionsNotifier,
          cacheExtent: cacheExtent,
        ),
      ),
    );
  }

  testWidgets('Empty list', (WidgetTester tester) async {
    await setUpWidgetTest(tester, itemCount: 0);

    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Separator 0'), findsNothing);
  });

  testWidgets('Short list', (WidgetTester tester) async {
    await setUpWidgetTest(tester, itemCount: 3);

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Separator 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Separator 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemTrailingEdge,
        _screenProportion(numberOfItems: 3, numberOfSeparators: 2));
  });

  testWidgets('Short list centered at 1 scrolled up',
      (WidgetTester tester) async {
    await setUpWidgetTest(tester, itemCount: 3, topItem: 1);

    await tester.drag(
        find.byType(PositionedList), const Offset(0, 2 * itemHeight));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Separator 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Separator 2'), findsNothing);
    expect(find.text('Item 3'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemTrailingEdge,
        _screenProportion(numberOfItems: 3, numberOfSeparators: 2));
  });

  testWidgets('List positioned with 0 at top', (WidgetTester tester) async {
    await setUpWidgetTest(tester);
    await tester.pump();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
    expect(find.text('Separator 6'), findsNothing);
    expect(find.text('Item 7'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 1, numberOfSeparators: 1));

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 5 at top', (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 5);
    await tester.pump();

    expect(find.text('Item 4'), findsNothing);
    expect(find.text('Separator 4'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);

    expect(find.text('Separator 10'), findsOneWidget);
    expect(find.text('Item 11'), findsOneWidget);
    expect(find.text('Separator 11'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 11)
            .itemTrailingEdge,
        1);
  });

  testWidgets('List positioned with 20 at bottom', (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 20, anchor: 1);
    await tester.pump();

    expect(find.text('Item 20'), findsNothing);
    expect(find.text('Item 19'), findsOneWidget);
    expect(find.text('Separator 19'), findsOneWidget);
    expect(find.text('Item 14'), findsOneWidget);
    expect(find.text('Separator 13'), findsOneWidget);
    expect(find.text('Item 13'), findsOneWidget);
    expect(find.text('Separator 12'), findsNothing);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 19)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 0, numberOfSeparators: 1));
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 20)
            .itemLeadingEdge,
        1);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 13)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: -0.5, numberOfSeparators: 0));
  });

  testWidgets('List positioned with item 20 at halfway',
      (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 20, anchor: 0.5);
    await tester.pump();

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 20)
            .itemLeadingEdge,
        0.5);
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 20)
            .itemTrailingEdge,
        0.5 + itemHeight / screenHeight);
  });

  testWidgets('List positioned with item 20 half off top of screen',
      (WidgetTester tester) async {
    await setUpWidgetTest(tester,
        topItem: 20, anchor: -(itemHeight / screenHeight) / 2);
    await tester.pump();

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 20)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: -0.5, numberOfSeparators: 0));
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 20)
            .itemTrailingEdge,
        _screenProportion(numberOfItems: 0.5, numberOfSeparators: 0));
  });

  testWidgets('List positioned with 5 at top then scroll up 2 items',
      (WidgetTester tester) async {
    await setUpWidgetTest(tester, topItem: 5);

    await tester.drag(find.byType(PositionedList),
        const Offset(0, 2 * (itemHeight + separatorHeight)));
    await tester.pump();

    expect(find.text('Separator 2'), findsNothing);
    expect(find.text('Item 3'), findsOneWidget);

    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: -1, numberOfSeparators: -1));
    expect(
        itemPositionsNotifier.itemPositions.value
            .firstWhere((position) => position.index == 3)
            .itemLeadingEdge,
        0);
  });
}

double _screenProportion(
        {required double numberOfItems, required double numberOfSeparators}) =>
    (numberOfItems * itemHeight + numberOfSeparators * separatorHeight) /
    screenHeight;
