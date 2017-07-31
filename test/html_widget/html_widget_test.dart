// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_widgets/src/html_widget/html_widget.dart';

Future<Null> _pumpWithDirectionality(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(new Directionality(
    textDirection: TextDirection.ltr,
    child: widget,
  ));
}

void main() {
  group('HtmlWidgets', () {
    testWidgets('HtmlText can be build from a Text Node',
        (WidgetTester tester) async {
      var phrase = 'this is a test';
      var tag = new dom.Text(phrase);
      var widget = new HtmlText(tag);

      await _pumpWithDirectionality(tester, widget);

      expect(find.text(phrase), findsOneWidget);
    });

    testWidgets('HtmlBold can be built from a <b> tag.',
        (WidgetTester tester) async {
      var tag = new dom.Element.tag('b');
      var widget = new HtmlBold(tag);

      await _pumpWithDirectionality(tester, widget);

      expect(find.byWidgetPredicate((widget) => widget is DefaultTextStyle),
          findsOneWidget);
    });

    testWidgets('HtmlUnderline can be built from a <u> tag',
        (WidgetTester tester) async {
      var tag = new dom.Element.tag('u');
      var widget = new HtmlUnderline(tag);

      await _pumpWithDirectionality(tester, widget);

      expect(find.byWidgetPredicate((widget) => widget is DefaultTextStyle),
          findsOneWidget);
    });

    testWidgets('HtmlBreak can be built from a <br/> tag',
        (WidgetTester tester) async {
      var tag = new dom.Element.html('<br/>');
      var widget = new HtmlUnderline(tag);

      await _pumpWithDirectionality(tester, widget);

      expect(find.byWidgetPredicate((widget) => widget is Container),
          findsOneWidget);
    });

    testWidgets('HtmlTable can be built from a <table> tag',
        (WidgetTester tester) async {
      var document = new dom.Document.html('''
           <table>
             <tr><td>1</td></tr>
             <tr><td>2</td></tr>
           </table>
          ''');
      var table = document.body.firstChild;
      var widget = new HtmlTable(table);

      await _pumpWithDirectionality(tester, widget);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
