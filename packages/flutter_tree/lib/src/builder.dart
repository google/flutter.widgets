// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import 'node_widget.dart';
import 'tree_node.dart';
import 'tree_state.dart';

/// Builds set of [nodes] respecting [state], [indent] and [iconSize].
Widget buildNodes(
    List<TreeNode> nodes, double indent, TreeState state, double iconSize) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var node in nodes)
        NodeWidget(
          treeNode: node,
          indent: indent,
          state: state,
          iconSize: iconSize,
        )
    ],
  );
}
