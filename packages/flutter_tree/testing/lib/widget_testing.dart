// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps widget to MaterialApp and pumps.
Future<void> wrapAndPump(WidgetTester tester, Widget widget) async {
  var wrapped = MaterialApp(
    home: SingleChildScrollView(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(child: widget),
    )),
  );
  await tester.pumpWidget(wrapped);
}
