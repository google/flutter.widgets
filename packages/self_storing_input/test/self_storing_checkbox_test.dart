// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter_test/flutter_test.dart';
import 'package:self_storing_input/self_storing_input.dart';

import 'testing/widget_testing.dart';

void main() {
  group('SelfStoringCheckbox', () {
    testWidgets('widget renders successfully if no parameters provided.',
        (WidgetTester tester) async {
      await wrapAndPump(tester, SelfStoringCheckbox('id'));
    });
  });
}
