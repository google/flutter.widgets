// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:scrollable_positioned_list_example/main.dart';

void main() {
  setUp(() {
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration(
        size: const Size(800, 900), window: RendererBinding.instance.window);
  });

  testWidgets('Start at 0', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScrollablePositionedListPage()));
    await tester.pump();
    expect(
        tester.getTopLeft(item(0)).dy -
            tester.getTopLeft(find.byType(ScrollablePositionedList)).dy,
        0);
    expect(find.text('First Item: 0'), findsOneWidget);
  });

  testWidgets('Scroll Up a little', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScrollablePositionedListPage()));
    await tester.drag(find.byType(ScrollablePositionedListPage), Offset(0, -5));
    await tester.pump();
    await tester.pump();
    expect(find.text('First Item: 0'), findsOneWidget);
  });

  testWidgets('Scroll to 100', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScrollablePositionedListPage()));
    await tester.tap(find.byKey(const ValueKey<String>('Scroll100')));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(item(100)).dy -
            tester.getTopLeft(find.byType(ScrollablePositionedList)).dy,
        0);
    expect(find.text('First Item: 100'), findsOneWidget);
  });

  testWidgets('Jump to 1000', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScrollablePositionedListPage()));
    await tester.tap(find.byKey(const ValueKey<String>('Jump1000')));
    await tester.pump();
    await tester.pump();
    expect(
        tester.getTopLeft(item(1000)).dy -
            tester.getTopLeft(find.byType(ScrollablePositionedList)).dy,
        0);
    expect(find.text('First Item: 1000'), findsOneWidget);
  });

  testWidgets('Scroll to 1000', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ScrollablePositionedListPage()));
    await tester.tap(find.byKey(const ValueKey<String>('Scroll1000')));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(item(1000)).dy -
            tester.getTopLeft(find.byType(ScrollablePositionedList)).dy,
        0);
    expect(find.text('First Item: 1000'), findsOneWidget);
  });
}

Finder item(int index) => find.ancestor(
    of: find.text('Item $index'), matching: find.byType(SizedBox));
