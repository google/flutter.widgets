// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(Demo());
}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final Key _key = ValueKey(22);
  final TreeController _controller = TreeController(allNodesExpanded: true);

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
                  height: 300,
                  width: 300,
                  child: buildTree(),
                ),
                RaisedButton(
                  child: Text("Expand All"),
                  onPressed: () => setState(() {
                    _controller.expandAll();
                  }),
                ),
                RaisedButton(
                  child: Text("Collapse All"),
                  onPressed: () => setState(() {
                    _controller.collapseAll();
                  }),
                ),
                RaisedButton(
                  child: Text("Expand node 22"),
                  onPressed: () => setState(() {
                    _controller.expandNode(_key);
                  }),
                ),
                RaisedButton(
                  child: Text("Collapse node 22"),
                  onPressed: () => setState(() {
                    _controller.collapseNode(_key);
                  }),
                ),
                FlatButton(
                    child: Text(
                      "Source Code",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async => await launch(
                        'https://github.com/google/flutter.widgets/tree/master/packages/flutter_simple_treeview/example')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTree() {
    return TreeView(
      treeController: _controller,
      nodes: [
        TreeNode(content: Text("node 1")),
        TreeNode(
          content: Icon(Icons.audiotrack),
          children: [
            TreeNode(content: Text("node 21")),
            TreeNode(
              content: Text("node 22"),
              key: _key,
              children: [
                TreeNode(
                  content: Icon(Icons.sentiment_very_satisfied),
                ),
              ],
            ),
            TreeNode(
              content: Text("node 23"),
            ),
          ],
        ),
      ],
    );
  }
}
