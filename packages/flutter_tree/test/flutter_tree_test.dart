// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tree/flutter_tree.dart';
import 'package:third_party.dart.flutter_tree.testing/widget_testing.dart';

void main() {
  testWidgets('Tree renders all nodes when expanded.',
      (WidgetTester tester) async {
    var widget = TreeView(
      allNodesExpanded: true,
      nodes: [
        TreeNode(content: Text('n0')),
        TreeNode(content: Text('n1')),
        TreeNode(
          content: Text('n2'),
          children: [
            TreeNode(content: Text('n3')),
            TreeNode(content: Text('n4')),
            TreeNode(
              content: Text('n5'),
              children: [
                TreeNode(content: Text('n6')),
              ],
            ),
          ],
        ),
      ],
    );
    await wrapAndPump(tester, widget);

    for (var i = 0; i < 7; i++) {
      expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'n$i'),
        findsOneWidget,
      );
    }
  });
}
