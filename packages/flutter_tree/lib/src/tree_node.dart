// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

/// One node of a tree.
class TreeNode {
  final List<TreeNode> children;
  final Widget content;

  /// The key is used to persist expanded state
  final Key key;

  TreeNode({Key key, this.children, this.content}) : key = key ?? UniqueKey();
}
