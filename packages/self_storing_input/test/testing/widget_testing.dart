// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [widget] to MaterialApp and pumps.
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

/// Wraps widget into sized and aligned container.
Widget sizeAndLayout(Widget child) => SizedBox(
      width: 5000,
      height: 5000,
      child: Align(alignment: Alignment.topLeft, child: child),
    );
