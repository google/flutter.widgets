// Copyright 2023 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
    ScrollOffsetListener? scrollOffsetListener,
    Axis? scrollDirection,
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
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(screenWidth, screenHeight);

    await tester.pumpWidget(
      MaterialApp(
        home: ScrollablePositionedList.builder(
          key: key,
          itemCount: itemCount,
          itemScrollController: itemScrollController,
          scrollOffsetListener: scrollOffsetListener,
          scrollDirection: scrollDirection ?? Axis.vertical,
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

  testWidgets('Manual scroll up 10 pixels', (WidgetTester tester) async {
    final scrollDistance = 50.0;

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final ScrollSum scrollSummer = ScrollSum();

    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollSummer.scrollOffsetListener,
        initialIndex: 5);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);

    await tester.drag(
        find.byType(ScrollablePositionedList), Offset(0, -scrollDistance));
    await tester.pumpAndSettle();

    expect(scrollSummer.totalScroll, scrollDistance);
  });

  testWidgets('Manual scroll left 10 pixels', (WidgetTester tester) async {
    final scrollDistance = 50.0;

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final ScrollSum scrollSummer = ScrollSum();

    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollSummer.scrollOffsetListener,
        scrollDirection: Axis.horizontal,
        initialIndex: 5);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);

    await tester.drag(
        find.byType(ScrollablePositionedList), Offset(-scrollDistance, 0));
    await tester.pumpAndSettle();

    expect(scrollSummer.totalScroll, scrollDistance);
  });

  testWidgets('Programmatic scroll to item 100 with programmatic recording on',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final ScrollSum scrollSummer = ScrollSum();

    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollSummer.scrollOffsetListener,
        scrollDirection: Axis.horizontal,
        initialIndex: 5);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));

    await tester.pumpAndSettle();

    expect(scrollSummer.totalScroll, 2 * screenHeight);
  });

  testWidgets('Programmatic scroll to item 100 with programmatic recording off',
      (WidgetTester tester) async {
    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final ScrollSum scrollSummer = ScrollSum(recordProgrammaticScrolls: false);

    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollSummer.scrollOffsetListener,
        scrollDirection: Axis.horizontal,
        initialIndex: 5);

    unawaited(
        itemScrollController.scrollTo(index: 100, duration: scrollDuration));

    await tester.pumpAndSettle();

    expect(scrollSummer.totalScroll, 0);
  });

  testWidgets('Manual scroll up 10 pixels with programmatic recording off',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;

    final itemScrollController = ItemScrollController();
    final itemPositionsListener = ItemPositionsListener.create();
    final ScrollSum scrollSummer = ScrollSum(recordProgrammaticScrolls: false);

    await setUpWidgetTest(tester,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollSummer.scrollOffsetListener,
        initialIndex: 5);

    expect(
        itemPositionsListener.itemPositions.value
            .firstWhere((position) => position.index == 5)
            .itemLeadingEdge,
        0);

    await tester.drag(
        find.byType(ScrollablePositionedList), Offset(0, -scrollDistance));
    await tester.pumpAndSettle();

    expect(scrollSummer.totalScroll, scrollDistance);
  });
}

class ScrollSum {
  final bool recordProgrammaticScrolls;
  double totalScroll = 0.0;
  final scrollOffsetListener;

  ScrollSum({this.recordProgrammaticScrolls = true})
      : scrollOffsetListener = ScrollOffsetListener.create(
            recordProgrammaticScrolls: recordProgrammaticScrolls) {
    scrollOffsetListener.changes.listen((event) {
      totalScroll += event;
    });
  }
}
