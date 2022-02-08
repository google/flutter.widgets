// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:scrollable_positioned_list/src/scroll_view.dart';

const screenHeight = 400.0;
const screenWidth = 400.0;
const itemHeight = screenHeight / 10.0;
const separatorHeight = screenHeight / 20.0;
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
    int? itemCount,
    ScrollPhysics? physics,
    bool addSemanticIndexes = true,
    int? semanticChildCount,
    EdgeInsets? padding,
    bool addRepaintBoundaries = true,
    bool addAutomaticKeepAlives = true,
  }) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.separated(
          itemCount: itemCount ?? defaultItemCount,
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) => SizedBox(
            height: itemHeight,
            child: Text('Item $index'),
          ),
          separatorBuilder: (context, index) => SizedBox(
            height: separatorHeight,
            child: Text('Separator $index'),
          ),
          key: key,
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
    await setUpWidgetTest(tester, itemPositionsListener: itemPositionsListener);

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
    expect(find.text('Separator 6'), findsNothing);
    expect(find.text('Item 7'), findsNothing);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 1, numberOfSeparators: 1));

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 7),
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
        home: ScrollablePositionedList.separated(
          itemCount: defaultItemCount,
          itemBuilder: (context, index) => SizedBox(
            height: itemHeight,
            child: Text('Item $index'),
          ),
          separatorBuilder: (context, index) => SizedBox(
            height: separatorHeight,
            child: Text('Separator $index'),
          ),
          itemPositionsListener: itemPositionsListener,
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
    expect(find.text('Separator 6'), findsNothing);
    expect(find.text('Item 7'), findsNothing);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 1, numberOfSeparators: 1));

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 7),
        isEmpty);
  });

  testWidgets('List positioned with 5 at top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener, initialIndex: 5);

    expect(find.text('Item 4'), findsNothing);
    expect(find.text('Separator 4'), findsNothing);
    expect(find.text('Item 5'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);
    expect(find.text('Separator 10'), findsOneWidget);
    expect(find.text('Item 11'), findsOneWidget);
    expect(find.text('Separator 11'), findsNothing);

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
    expect(tester.getTopLeft(find.text('Item 8')).dy,
        screenHeight / 2 - itemHeight - separatorHeight);
    expect(tester.getTopLeft(find.text('Item 10')).dy,
        screenHeight / 2 + itemHeight + separatorHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemLeadingEdge,
        0.5);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 8)
            .itemLeadingEdge,
        0.5 - _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 10)
            .itemLeadingEdge,
        0.5 + _screenProportion(numberOfItems: 1, numberOfSeparators: 1));
  });

  testWidgets('Scroll to 9 half way off top', (WidgetTester tester) async {
    final itemPositionsListener = ItemPositionsListener.create();
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(tester,
        itemPositionsListener: itemPositionsListener,
        itemScrollController: itemScrollController);

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
        _screenProportion(numberOfItems: -0.5, numberOfSeparators: 0));
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        _screenProportion(numberOfItems: 0.5, numberOfSeparators: 0));
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
        _screenProportion(numberOfItems: -0.5, numberOfSeparators: 0));
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 9)
            .itemTrailingEdge,
        _screenProportion(numberOfItems: 0.5, numberOfSeparators: 0));
  });

  testWidgets('List positioned with 9 at middle scroll to 16 at bottom',
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

    expect(tester.getBottomRight(find.text('Item 15')).dy,
        screenHeight - separatorHeight);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 15)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 0, numberOfSeparators: 1));
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

  testWidgets('correct index semantics', (WidgetTester tester) async {
    await setUpWidgetTest(tester, initialIndex: 5);

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, 4 * itemHeight));
    await tester.pumpAndSettle();

    final indexSemantics3 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 3'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics3.index, 3);
    final indexSemantics4 = tester.widget<IndexedSemantics>(find.ancestor(
        of: find.text('Item 4'), matching: find.byType(IndexedSemantics)));
    expect(indexSemantics4.index, 4);
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

  testWidgets('padding test - centered at top', (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    await setUpWidgetTest(
      tester,
      itemScrollController: itemScrollController,
      padding: const EdgeInsets.all(10),
    );

    expect(tester.getTopLeft(find.text('Item 0')), const Offset(10, 10));
    expect(tester.getTopLeft(find.text('Item 1')),
        const Offset(10, 10 + itemHeight + separatorHeight));
    expect(tester.getTopRight(find.text('Item 1')),
        const Offset(screenWidth - 10, 10 + itemHeight + separatorHeight));

    unawaited(
        itemScrollController.scrollTo(index: 494, duration: scrollDuration));
    await tester.pumpAndSettle();

    await tester.drag(
        find.byType(ScrollablePositionedList), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.getBottomRight(find.text('Item 499')),
        const Offset(screenWidth - 10, screenHeight - 10));
  });

  testWidgets('padding test - centered sliver not at top',
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
        const Offset(10, 10 + 2 * (separatorHeight + itemHeight)));
    expect(
        tester.getTopRight(find.text('Item 3')),
        const Offset(
            screenWidth - 10, 10 + 3 * (itemHeight + separatorHeight)));
  });

  testWidgets('no repaint bounderies', (WidgetTester tester) async {
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

  testWidgets('List can be keyed', (WidgetTester tester) async {
    final key = ValueKey('key');

    await setUpWidgetTest(tester, key: key);

    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('Empty list then update to single item list',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final itemCount = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: itemCount,
          builder: (context, itemCount, child) {
            return ScrollablePositionedList.separated(
              initialScrollIndex: 0,
              initialAlignment: 0,
              itemCount: itemCount,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (context, index) => SizedBox(
                height: itemHeight,
                child: Text('Item $index'),
              ),
              separatorBuilder: (context, index) => SizedBox(
                height: separatorHeight,
                child: Text('Separator $index'),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    itemCount.value = 1;
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 0'), findsNothing);
  });

  testWidgets('ItemPositions: Empty list then update to 10 items list',
      (WidgetTester tester) async {
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue =
        const Size(screenWidth, screenHeight);

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final itemCount = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: itemCount,
          builder: (context, itemCount, child) {
            return ScrollablePositionedList.separated(
              initialScrollIndex: 0,
              initialAlignment: 0,
              itemCount: itemCount,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemBuilder: (context, index) => SizedBox(
                height: itemHeight,
                child: Text('Item $index'),
              ),
              separatorBuilder: (context, index) => SizedBox(
                height: separatorHeight,
                child: Text('Separator $index'),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsNothing);
    expect(find.text('Separator 0'), findsNothing);
    expect(itemPositionsListener.itemPositions.value, []);

    itemCount.value = 10;
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Separator 5'), findsOneWidget);
    expect(find.text('Item 6'), findsOneWidget);
    expect(find.text('Separator 6'), findsNothing);
    expect(find.text('Item 7'), findsNothing);

    expect(itemPositionsListener.itemPositions.value, isNotEmpty);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 0)
            .itemLeadingEdge,
        0);
    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemTrailingEdge,
        1 - _screenProportion(numberOfItems: 1, numberOfSeparators: 1));

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 6)
            .itemTrailingEdge,
        1);
    expect(
        itemPositionsListener.itemPositions.value
            .where((position) => position.index == 7),
        isEmpty);
  });
}

double _screenProportion(
        {required double numberOfItems, required double numberOfSeparators}) =>
    (numberOfItems * itemHeight + numberOfSeparators * separatorHeight) /
    screenHeight;
