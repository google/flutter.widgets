// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/foundation.dart';

/// The state of a tree.
///
/// This state is passed to all tree nodes.
class TreeState {
  final bool allNodesExpanded;
  final Map<Key, bool> state = <Key, bool>{};

  TreeState(this.allNodesExpanded);

  bool isNodeExpanded(Key key) {
    return state[key] ?? allNodesExpanded;
  }

  void toggleNodeExpanded(Key key) {
    state[key] = !isNodeExpanded(key);
  }
}
