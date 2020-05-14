// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import 'builder.dart';
import 'tree_node.dart';
import 'tree_state.dart';

/// Tree view with collapsable and expandable nodes.
class TreeView extends StatefulWidget {
  final List<TreeNode> nodes;
  final double indent;
  final double iconSize;
  final bool allNodesExpanded;

  const TreeView(
      {Key key,
      this.nodes,
      this.indent = 40,
      this.allNodesExpanded = false,
      this.iconSize})
      : super(key: key);

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  TreeState _state;

  @override
  void initState() {
    _state = TreeState(widget.allNodesExpanded);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildNodes(widget.nodes, widget.indent, _state, widget.iconSize);
  }
}
