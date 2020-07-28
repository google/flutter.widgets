// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_storing_input/self_storing_input.dart';
import 'package:self_storing_input/src/self_storing_text/overlay_box.dart';

import 'testing/widget_testing.dart';

/// Saves and loads values fast and successfully.
/// Validation always returns true.
class _HappyTestSaver implements Saver {
  Map<String, dynamic> storage = {};

  @override
  Future<T> load<T>(Object itemKey) async {
    return storage[itemKey];
  }

  @override
  OperationResult validate<T>(Object itemKey, T value) {
    return OperationResult.success();
  }

  @override
  Future<OperationResult> save<T>(Object itemKey, T value) async {
    storage[itemKey] = value;
    return OperationResult.success();
  }
}

void main() {
  group('SelfStoringText', () {
    testWidgets('respects empty value replacer', (WidgetTester tester) async {
      var saver = _HappyTestSaver();
      SelfStoringText textWidget = SelfStoringText(
        'itemKey',
        saver: saver,
      );
      await wrapAndPump(tester, sizeAndLayout(textWidget));
      await tester.pumpAndSettle();

      // Check the text value.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == textWidget.emptyText),
        findsOneWidget,
      );
    });

    testWidgets('loads value', (WidgetTester tester) async {
      // Prepare the widget.
      var itemKey = 'itemKey';
      var value = 'value';
      var saver = _HappyTestSaver()..storage[itemKey] = value;
      SelfStoringText textWidget = SelfStoringText(
        itemKey,
        saver: saver,
      );
      await wrapAndPump(tester, sizeAndLayout(textWidget));
      await tester.pumpAndSettle();

      // Check the text value.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == value),
        findsOneWidget,
      );
    });

    testWidgets('clear value', (WidgetTester tester) async {
      // Prepare the widget.
      var itemKey = 'itemKey';
      var value = 'value';
      var saver = _HappyTestSaver()..storage[itemKey] = value;
      SelfStoringText textWidget = SelfStoringText(
        itemKey,
        saver: saver,
      );
      await wrapAndPump(tester, sizeAndLayout(textWidget));
      await tester.pumpAndSettle();

      // Click the edit button.
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Check the text value.
      expect(
        find.byWidgetPredicate((widget) =>
            widget is TextFormField && widget.controller.text == value),
        findsOneWidget,
      );

      // Clear value.
      await tester.tap(find.byKey(clearButtonKey));
      await tester.pumpAndSettle();

      // Click OK button.
      await tester.tap(find.byKey(okButtonKey));
      await tester.pumpAndSettle();

      // Check the text value.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == textWidget.emptyText),
        findsOneWidget,
      );

      expect(saver.storage[itemKey], null);
    });

    testWidgets('happy path', (WidgetTester tester) async {
      // Prepare the widget.
      var itemKey = 'itemKey';
      var value = 'value';
      var saver = _HappyTestSaver();
      SelfStoringText textWidget = SelfStoringText(
        itemKey,
        saver: saver,
      );
      await wrapAndPump(tester, sizeAndLayout(textWidget));
      await tester.pumpAndSettle();

      // Check the text value.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == textWidget.emptyText),
        findsOneWidget,
      );

      // Click the edit button.
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Enter 'hi' into the TextField.
      await tester.enterText(find.byType(TextFormField), value);

      // Click OK button.
      await tester.tap(find.byKey(okButtonKey));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Check the entered value is applied in UI.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == value),
        findsOneWidget,
      );
      // And in storage.
      expect(saver.storage[itemKey], 'value');
      // And overlay is closed.
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('cancel editing', (WidgetTester tester) async {
      var itemKey = 'itemKey';
      var saver = _HappyTestSaver();
      SelfStoringText textWidget = SelfStoringText(
        itemKey,
        saver: saver,
      );
      await wrapAndPump(tester, sizeAndLayout(textWidget));
      await tester.pumpAndSettle();

      // Click the edit button.
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Enter 'hi' into the TextField.
      await tester.enterText(find.byType(TextFormField), 'hi');

      // Click cancel button.
      await tester.tap(find.byKey(cancelButtonKey));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Check the entered value is not applied in UI.
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == textWidget.emptyText),
        findsOneWidget,
      );
      // And in storage.
      expect(saver.storage.containsKey(itemKey), false);
      // And overlay is closed.
      expect(find.byType(TextFormField), findsNothing);
    });
  });
}
