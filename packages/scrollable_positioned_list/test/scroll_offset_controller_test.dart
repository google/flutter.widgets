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
    ScrollOffsetController? scrollOffsetController,
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
          scrollOffsetController: scrollOffsetController,
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

  testWidgets('Programtically scroll down 50 pixels',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;

    ScrollOffsetController scrollOffsetController = ScrollOffsetController();

    await setUpWidgetTest(
      tester,
      scrollOffsetController: scrollOffsetController,
      initialIndex: 5,
    );

    final originalOffest = tester.getTopLeft(find.text('Item 5')).dy;

    unawaited(scrollOffsetController.animateScroll(
      offset: -scrollDistance,
      duration: scrollDuration,
    ));
    await tester.pumpAndSettle();

    final newOffset = tester.getTopLeft(find.text('Item 5')).dy;

    expect(newOffset - originalOffest, scrollDistance);
  });

  testWidgets('Programtically scroll left 50 pixels',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;

    ScrollOffsetController scrollOffsetController = ScrollOffsetController();

    await setUpWidgetTest(
      tester,
      scrollOffsetController: scrollOffsetController,
      initialIndex: 5,
      scrollDirection: Axis.horizontal,
    );

    final originalOffest = tester.getTopLeft(find.text('Item 5')).dx;

    unawaited(scrollOffsetController.animateScroll(
      offset: -scrollDistance,
      duration: scrollDuration,
    ));
    await tester.pumpAndSettle();

    final newOffset = tester.getTopLeft(find.text('Item 5')).dx;

    expect(newOffset - originalOffest, scrollDistance);
  });

  testWidgets('Programtically scroll down 50 pixels, stop half way',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;

    ScrollOffsetController scrollOffsetController = ScrollOffsetController();

    await setUpWidgetTest(
      tester,
      scrollOffsetController: scrollOffsetController,
      initialIndex: 5,
    );

    final originalOffest = tester.getTopLeft(find.text('Item 5')).dy;

    unawaited(scrollOffsetController.animateScroll(
      offset: -scrollDistance,
      duration: scrollDuration,
    ));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    await tester.tap(find.byType(ScrollablePositionedList));
    await tester.pumpAndSettle();

    final newOffset = tester.getTopLeft(find.text('Item 5')).dy;

    expect(newOffset - originalOffest, scrollDistance ~/ 2);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'Programtically scroll down 50 pixels, stop half way and go back 12',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;
    final scrollBack = 12.0;

    ScrollOffsetController scrollOffsetController = ScrollOffsetController();

    await setUpWidgetTest(
      tester,
      scrollOffsetController: scrollOffsetController,
      initialIndex: 5,
    );

    final originalOffest = tester.getTopLeft(find.text('Item 5')).dy;

    unawaited(scrollOffsetController.animateScroll(
      offset: -scrollDistance,
      duration: scrollDuration,
    ));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    unawaited(scrollOffsetController.animateScroll(
      offset: scrollBack,
      duration: scrollDuration,
    ));
    await tester.pumpAndSettle();

    final newOffset = tester.getTopLeft(find.text('Item 5')).dy;

    expect(newOffset - originalOffest, (scrollDistance ~/ 2) - scrollBack);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'Programtically scroll down 50 pixels, stop half way and then programtically scroll to iten 100',
      (WidgetTester tester) async {
    final scrollDistance = 50.0;

    ScrollOffsetController scrollOffsetController = ScrollOffsetController();
    ItemScrollController itemScrollController = ItemScrollController();

    await setUpWidgetTest(
      tester,
      scrollOffsetController: scrollOffsetController,
      itemScrollController: itemScrollController,
      initialIndex: 5,
    );

    unawaited(scrollOffsetController.animateScroll(
      offset: -scrollDistance,
      duration: scrollDuration,
    ));
    await tester.pump();
    await tester.pump();
    await tester.pump(scrollDuration ~/ 2);

    unawaited(itemScrollController.scrollTo(
      index: 100,
      duration: scrollDuration,
    ));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Item 100')).dy, 0);

    await tester.pumpAndSettle();
  });
}
