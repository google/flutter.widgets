// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('TreeView', () {
    testWidgets('renders all nodes when expanded.',
        (WidgetTester tester) async {
      var widget = TreeView(
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
      await _wrapAndPump(tester, widget);

      for (var i = 0; i < 7; i++) {
        expect(
          find.byWidgetPredicate(
              (widget) => widget is Text && widget.data == 'n$i'),
          findsOneWidget,
        );
      }
    });

    test('generates unique key if the key is null.', () {
      var tree = TreeView(nodes: [
        TreeNode(),
        TreeNode(
          key: ValueKey(1),
          children: [TreeNode()],
        )
      ]);

      expect(tree.nodes[0].key, isNotNull);
      expect(tree.nodes[1].key, ValueKey(1));
      expect(tree.nodes[0].key == tree.nodes[1].children![0].key, false);
    });

    test('throws if the key is duplicate.', () {
      var nodes = [TreeNode(key: ValueKey(1)), TreeNode(key: ValueKey(1))];

      expect(() => TreeView(nodes: nodes), throwsA(isA<ArgumentError>()));
    });

    test('has immutable node list.', () {
      try {
        TreeView(nodes: []).nodes.add(TreeNode());
      } catch (e) {
        print(e.runtimeType);
      }
      expect(
          () => TreeView(nodes: []).nodes.add(TreeNode()),
          throwsA(
              predicate((dynamic e) => e.toString().contains('unmodifiable'))));
    });
  });
}
