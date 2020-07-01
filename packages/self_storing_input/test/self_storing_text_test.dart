// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_storing_input/self_storing_input.dart';
import 'package:self_storing_input/src/primitives/overlay_builder.dart';
import 'package:self_storing_input/src/self_storing_text/overlay_box.dart';

/// Wraps widget to MaterialApp and pumps.
Future<void> _wrapAndPump(WidgetTester tester, Widget widget) async {
  var wrapped = MaterialApp(
    home: SingleChildScrollView(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(child: widget),
    )),
  );
  await tester.pumpWidget(wrapped);
}

void main() {
  group('SelfStoringText', () {
    testWidgets('widget renders successfully if no parameters provided.',
        (WidgetTester tester) async {
      await _wrapAndPump(tester, SelfStoringText('id'));
    });

    testWidgets('overlay renders successfully if trivial parameters provided.',
        (WidgetTester tester) async {
      var style = SelfStoringTextStyle();
      var content = OverlayBox(SharedState(
        saver: NoOpSaver(),
        style: style,
      ));

      await _wrapAndPump(
          tester, applyOverlayStyle(style.overlayStyle, content));
    });
  });
}
