// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_widgets/src/tagged_text/tagged_text.dart';

const TextStyle greetingStyle = const TextStyle(fontWeight: FontWeight.w100);
const TextStyle nameStyle = const TextStyle(fontWeight: FontWeight.w200);
const TextStyle defaultStyle = const TextStyle(fontWeight: FontWeight.w500);

void main() {
  group('$TaggedText', () {
    testWidgets('without tags', (tester) async {
      final content = 'Hello, Bob';
      final widget = new TaggedText(
        content: content,
        tagToTextSpanBuilder: {},
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [new TextSpan(text: content)]);
    });

    testWidgets('with tags', (tester) async {
      final widget = new TaggedText(
        content: '<greeting>Hello</greeting>, my name is <name>George</name>!',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello', style: greetingStyle),
        new TextSpan(text: ', my name is '),
        new TextSpan(text: 'George', style: nameStyle),
        new TextSpan(text: '!'),
      ]);
    });

    testWidgets('content tags are case insensitive', (tester) async {
      final widget = new TaggedText(
        content: '<GREEting>Hello</GREEting>, my name is <nAme>George</nAme>!',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello', style: greetingStyle),
        new TextSpan(text: ', my name is '),
        new TextSpan(text: 'George', style: nameStyle),
        new TextSpan(text: '!'),
      ]);
    });

    testWidgets('asserts tags are not nested', (tester) async {
      final widget = new TaggedText(
        content: '<greeting>Hello, my name is <name>George</name></greeting>!',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(widget));

      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('asserts all tags in content are found', (tester) async {
      final widget = new TaggedText(
        content:
            '<salutation>Hello</salutation>, my name is <name>George</name>!',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(widget));

      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('rebuilds when content changes', (tester) async {
      final widget = new TaggedText(
        content: 'Hello, Bob',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );
      await tester.pumpWidget(wrap(widget));
      final newWidget = new TaggedText(
        content: 'Hello, <name>Bob</name>',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(newWidget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello, '),
        new TextSpan(text: 'Bob', style: nameStyle),
      ]);
    });

    testWidgets('rebuilds when tagToTextSpanBuilder changes', (tester) async {
      final widget = new TaggedText(
        content: 'Hello, <name>Bob</name>',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );
      await tester.pumpWidget(wrap(widget));
      final updatedStyle = const TextStyle(decoration: TextDecoration.overline);
      final newWidget = new TaggedText(
        content: 'Hello, <name>Bob</name>',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: updatedStyle),
        },
      );

      await tester.pumpWidget(wrap(newWidget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello, '),
        new TextSpan(text: 'Bob', style: updatedStyle),
      ]);
    });

    testWidgets('does not rebuild when tagToTextSpanBuilder stays the same',
        (tester) async {
      // Set up.
      final mockTextSpanBuilder = new MockTextSpanBuilder();
      final nameSpan = new TextSpan(text: 'Bob', style: nameStyle);
      when(mockTextSpanBuilder.call(any)).thenReturn(nameSpan);

      final content = 'Hello, <name>Bob</name>';
      final tagToTextSpanBuilder = <String, TextSpanBuilder>{
        // TODO Eliminate this wrapper when the Dart 2 FE
        // supports mocking and tearoffs.
        'name': (x) => mockTextSpanBuilder(x),
      };
      final widget = new TaggedText(
        content: content,
        tagToTextSpanBuilder: tagToTextSpanBuilder,
      );
      await tester.pumpWidget(wrap(widget));

      // Clone map to make sure that equality is checked by the contents of the
      // map.
      final newWidget = new TaggedText(
        content: content,
        tagToTextSpanBuilder: new Map.from(tagToTextSpanBuilder),
      );

      // Act.
      await tester.pumpWidget(wrap(newWidget));

      // Assert.
      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello, '),
        nameSpan,
      ]);
      verify(mockTextSpanBuilder.call(any)).called(1);
    });

    testWidgets('requires tag names to be lower case', (tester) async {
      expect(
          () => new TaggedText(
                content: 'Hello, <name>Bob</name>',
                tagToTextSpanBuilder: {
                  'nAme': (text) => new TextSpan(text: text, style: nameStyle),
                },
              ),
          throwsA(anything));
    });

    testWidgets('throws error when known HTML tags are used', (tester) async {
      expect(() {
        TaggedText(
          content: 'Hello, <link>Bob</link>',
          tagToTextSpanBuilder: {
            'link': (text) => new TextSpan(text: text, style: nameStyle),
          },
        );
      }, throwsA(anything));
    });

    testWidgets('ignores non-elements', (tester) async {
      final widget = new TaggedText(
        content: 'Hello, <!-- comment is not an element and is ignored -->'
            '<name>Bob</name>',
        tagToTextSpanBuilder: {
          'name': (text) => new TextSpan(text: text, style: nameStyle),
        },
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.text, isNull);
      expect(richText.text.children, [
        new TextSpan(text: 'Hello, '),
        new TextSpan(text: 'Bob', style: nameStyle),
      ]);
    });

    testWidgets('renders correct input styles', (tester) async {
      final widget = new TaggedText(
        content: '<greeting>Hello</greeting>',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
        },
        style: defaultStyle,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textScaleFactor: 1.5,
        maxLines: 2,
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.text.style, equals(defaultStyle));
      expect(richText.textAlign, equals(TextAlign.center));
      expect(richText.textDirection, equals(TextDirection.rtl));
      expect(richText.softWrap, isFalse);
      expect(richText.overflow, equals(TextOverflow.ellipsis));
      expect(richText.textScaleFactor, equals(1.5));
      expect(richText.maxLines, equals(2));
    });

    testWidgets(
        'uses 1.0 text scale factor when not specified and '
        'MediaQuery unavailable', (tester) async {
      final widget = new TaggedText(
        content: '<greeting>Hello</greeting>',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
        },
        // Text scale factor not specified!
      );

      await tester.pumpWidget(wrap(widget));

      final richText = findRichTextWidget(tester);
      expect(richText.textScaleFactor, equals(1.0));
    });

    testWidgets('uses MediaQuery text scale factor when available',
        (tester) async {
      final widget = new TaggedText(
        content: '<greeting>Hello</greeting>',
        tagToTextSpanBuilder: {
          'greeting': (text) => new TextSpan(text: text, style: greetingStyle),
        },
        // Text scale factor not specified!
      );
      final expectedTextScaleFactor = 123.4;

      await tester.pumpWidget(wrap(MediaQuery(
        data: MediaQueryData(textScaleFactor: expectedTextScaleFactor),
        child: widget,
      )));

      final richText = findRichTextWidget(tester);
      expect(richText.textScaleFactor, equals(expectedTextScaleFactor));
    });
  });
}

RichText findRichTextWidget(WidgetTester tester) {
  final richTextFinder = find.byType(RichText);
  expect(richTextFinder, findsOneWidget);
  return tester.widget(richTextFinder) as RichText;
}

Widget wrap(Widget widget) {
  return new Directionality(
    textDirection: TextDirection.ltr,
    child: widget,
  );
}

class MockTextSpanBuilder extends Mock {
  TextSpan call(String text);
}
