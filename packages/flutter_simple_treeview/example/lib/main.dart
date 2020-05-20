// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

Future main() {
  runApp(Demo());
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("FLUTTER-SIMPLE-TREEVIEW"),
                SizedBox(height: 20),
                SizedBox(
                  height: 500,
                  width: 500,
                  child: buildTree(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTree() {
    return TreeView(
      allNodesExpanded: true,
      nodes: [
        TreeNode(content: Text("node 1")),
        TreeNode(
          content: Icon(Icons.audiotrack),
          children: [
            TreeNode(content: Text("node 21")),
            TreeNode(
              content: Text("node 22"),
            ),
            TreeNode(
              content: Text("node 23"),
              children: [
                TreeNode(content: Icon(Icons.sentiment_very_satisfied)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
