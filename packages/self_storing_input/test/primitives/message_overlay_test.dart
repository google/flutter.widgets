// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter_test/flutter_test.dart';
import 'package:self_storing_input/self_storing_input.dart';
import 'package:self_storing_input/src/primitives/message_overlay.dart';
import 'package:self_storing_input/src/primitives/overlay_builder.dart';

import '../testing/widget_testing.dart';

void main() {
  group('MessageOverlay', () {
    testWidgets('renders successfully if trivial parameters provided.',
        (WidgetTester tester) async {
      var style = OverlayStyle.forMessage();
      var content = MessageOverlay(
        style: style,
        overlayController: OverlayController(),
      );
      await wrapAndPump(tester, applyOverlayStyle(style, content));
    });
  });
}
