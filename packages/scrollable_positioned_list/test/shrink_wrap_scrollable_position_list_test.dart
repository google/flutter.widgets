// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const itemCount = 500;
const scrollDuration = Duration(seconds: 1);

void main() {
  Future<void> setUpWidgetTest(
    WidgetTester tester, {
    ItemScrollController? itemScrollController,
    ItemPositionsListener? itemPositionsListener,
    EdgeInsets? padding,
    int initialIndex = 0,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        // Use flex layout to ensure that the minimum height is not limited to screenHeight
        home: Column(children: [
          // Use Constrained to make max height not more than screenHeight
          ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: screenHeight, maxWidth: screenWidth),
            child: ScrollablePositionedList.builder(
              itemCount: itemCount,
              initialScrollIndex: initialIndex,
              itemScrollController: itemScrollController,
              itemBuilder: (context, index) => SizedBox(
                height: itemHeight,
                child: Text('Item $index'),
              ),
              itemPositionsListener: itemPositionsListener,
              shrinkWrap: true,
              padding: padding,
            ),
          ),
        ]),
      ),
    );
  }

  testWidgets('List positioned with 0 at top and shrink wrap',
      (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester, itemPositionsListener: itemPositionsListener);

    expect(tester.getTopLeft(find.text('Item 0')).dy, 0);
    expect(tester.getBottomRight(find.text('Item 9')).dy, screenHeight);
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

  testWidgets('Scroll to 1 then 2 (both already on screen) with shrink wrap',
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
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 1)
            .itemLeadingEdge,
        0);
    expect(tester.getTopLeft(find.text('Item 1')).dy, 0);

    unawaited(
        itemScrollController.scrollTo(index: 2, duration: scrollDuration));
    await tester.pump();
    await tester.pump(scrollDuration);

    expect(find.text('Item 1'), findsNothing);
    expect(tester.getTopLeft(find.text('Item 2')).dy, 0);

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

  testWidgets(
      'Scroll to 5 (already on screen) and then back to 0 with shrink wrap',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    unawaited(
        itemScrollController.scrollTo(index: 5, duration: scrollDuration));
    await tester.pumpAndSettle();
    unawaited(
        itemScrollController.scrollTo(index: 0, duration: scrollDuration));
    await tester.pumpAndSettle();

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

  testWidgets('Scroll to 100 (not already on screen) with shrink wrap',
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
            .firstWhere((position) => position.index == 109)
            .itemTrailingEdge,
        1);
  });

  testWidgets('Jump to 100 with shrink wrap', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener);

    itemScrollController.jumpTo(index: 100);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);
    expect(tester.getBottomRight(find.text('Item 109')).dy, screenHeight);

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

  testWidgets('padding test - centered sliver at bottom with shrink wrap',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 1')),
        const Offset(10, 10 + itemHeight));
    expect(tester.getBottomRight(find.text('Item 1')),
        const Offset(screenWidth - 10, 10 + 2 * itemHeight));

    unawaited(
        itemScrollController.scrollTo(index: 490, duration: scrollDuration));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 499')),
        const Offset(10, screenHeight - itemHeight - 10));
  });

  testWidgets('padding test - centered sliver not at bottom',
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
}
