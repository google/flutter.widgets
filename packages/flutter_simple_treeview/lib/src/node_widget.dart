// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import 'builder.dart';
import 'primitives/tree_controller.dart';
import 'primitives/tree_node.dart';

/// Widget that displays one [TreeNode] and its children.
class NodeWidget extends StatefulWidget {
  final TreeNode treeNode;
  final double? indent;
  final double? iconSize;
  final TreeController state;

  const NodeWidget(
      {Key? key,
      required this.treeNode,
      this.indent,
      required this.state,
      this.iconSize})
      : super(key: key);

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool get _isLeaf {
    return widget.treeNode.children == null ||
        widget.treeNode.children!.isEmpty;
  }

  bool get _isExpanded {
    return widget.state.isNodeExpanded(widget.treeNode.key!);
  }

  @override
  Widget build(BuildContext context) {
    var icon = _isLeaf
        ? null
        : _isExpanded
            ? Icons.expand_more
            : Icons.chevron_right;

    var onIconPressed = _isLeaf
        ? null
        : () => setState(
            () => widget.state.toggleNodeExpanded(widget.treeNode.key!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              iconSize: widget.iconSize ?? 24.0,
              icon: Icon(icon),
              onPressed: onIconPressed,
            ),
            widget.treeNode.content,
          ],
        ),
        if (_isExpanded && !_isLeaf)
          Padding(
            padding: EdgeInsets.only(left: widget.indent!),
            child: buildNodes(widget.treeNode.children!, widget.indent,
                widget.state, widget.iconSize),
          )
      ],
    );
  }
}
