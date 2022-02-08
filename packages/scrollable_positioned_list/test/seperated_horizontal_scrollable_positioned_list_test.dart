// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemWidth = screenWidth / 10.0;
const separatorWidth = screenWidth / 20.0;
const itemCount = 500;
const scrollDuration = Duration(seconds: 1);
const tolerance = 10e-5;

void main() {
  Future<void> setUpWidgetTest(
    WidgetTester tester, {
    ItemScrollController? itemScrollController,
    ItemPositionsListener? itemPositionsListener,
    bool reverse = false,
    EdgeInsets? padding,
    int initialScrollIndex = 0,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.separated(
          itemCount: itemCount,
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) => SizedBox(
            width: itemWidth,
            child: Text('Item $index'),
          ),
          separatorBuilder: (context, index) => SizedBox(
            width: separatorWidth,
            child: Text('Separator $index'),
          ),
          itemPositionsListener: itemPositionsListener,
          scrollDirection: Axis.horizontal,
          reverse: reverse,
          padding: padding,
          initialScrollIndex: initialScrollIndex,
        ),
      ),
    );
  }

  testWidgets('List positioned with 0 at left', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester, itemPositionsListener: itemPositionsListener);

    expect(tester.getTopLeft(find.text('Item 0')).dx, 0);
    expect(tester.getBottomLeft(find.text('Item 1')).dx,
        itemWidth + separatorWidth);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 1)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
  });

  testWidgets('Scroll to 2 (already on screen)', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 2, duration: scrollDuration));
    await tester.pump();
    await tester.pump(scrollDuration);

    expect(find.text('Item 1'), findsNothing);
    expect(tester.getTopLeft(find.text('Item 2')).dx, 0);
    expect(
        tester.getTopLeft(find.text('Item 3')).dx, itemWidth + separatorWidth);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 3)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
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
    await tester.pumpAndSettle();

    expect(find.text('Item 99'), findsNothing);
    expect(find.text('Item 100'), findsOneWidget);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 101)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
  });

  testWidgets('Jump to 100', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 100);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 100')).dx, 0);
    expect(tester.getTopLeft(find.text('Item 101')).dx,
        itemWidth + separatorWidth);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 100)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 101)
            .itemLeadingEdge,
        _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
  });

  testWidgets('padding test - centered sliver at left',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 1')),
        const Offset(10 + itemWidth + separatorWidth, 10));
    expect(tester.getBottomRight(find.text('Item 1')),
        const Offset(10 + 2 * itemWidth + separatorWidth, screenHeight - 10));

    unawaited(
        itemScrollController.scrollTo(index: 494, duration: scrollDuration));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(find.text('Item 499')),
        const Offset(screenWidth - 10, screenHeight - 10));
  });

  testWidgets('padding test - centered sliver not at left',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      initialScrollIndex: 2,
      padding: const EdgeInsets.all(10),
    );

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 2')),
        const Offset(10 + 2 * (itemWidth + separatorWidth), 10));
    expect(tester.getTopLeft(find.text('Item 3')),
        const Offset(10 + 3 * (itemWidth + separatorWidth), 10));

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 2)
            .itemLeadingEdge,
        closeTo(
            10 / screenWidth + 2 * ((itemWidth + separatorWidth) / screenWidth),
            tolerance));
  });
}

double _screenProportion(
        {required double numberOfItems, required double numberOfSeparators}) =>
    (numberOfItems * itemWidth + numberOfSeparators * separatorWidth) /
    screenHeight;
