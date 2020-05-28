// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/src/primitives/tree_controller.dart';
import 'package:test/test.dart';

void main() {
  Key k1 = UniqueKey();
  Key k2 = UniqueKey();

  test('Initial state is equal to default state.', () {
    for (var allExpanded in [true, false]) {
      var state = TreeController(allNodesExpanded: allExpanded);
      expect(state.isNodeExpanded(k1), allExpanded);
    }
  });

  test('Toggle works.', () {
    for (var allExpanded in [true, false]) {
      var state = TreeController(allNodesExpanded: allExpanded);
      state.toggleNodeExpanded(k1);
      expect(state.isNodeExpanded(k1), !allExpanded);
      state.toggleNodeExpanded(k1);
      expect(state.isNodeExpanded(k1), allExpanded);
    }
  });

  test('States are independant.', () {
    for (var allExpanded in [true, false]) {
      var state = TreeController(allNodesExpanded: allExpanded);
      state.toggleNodeExpanded(k1);
      expect(state.isNodeExpanded(k2), allExpanded);
      state.toggleNodeExpanded(k1);
      expect(state.isNodeExpanded(k2), allExpanded);
      state.toggleNodeExpanded(k2);
      expect(state.isNodeExpanded(k1), allExpanded);
    }
  });
}
