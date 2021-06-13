// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import 'trees/controller_usage.dart';
import 'trees/tree_from_json.dart';

void main() {
  runApp(Demo());
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('flutter_simple_treeview Demo'),
            actions: [
              TextButton(
                  child: Text(
                    "Source Code",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async => await launch(
                      'https://github.com/google/flutter.widgets/tree/master/packages/flutter_simple_treeview/example')),
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: "Tree Controller Usage"),
                Tab(text: "Tree From JSON"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              buildBodyFrame(ControllerUsage()),
              buildBodyFrame(TreeFromJson()),
            ],
          ),
        ),
      ),
    );
  }

  /// Adds scrolling and padding to the [content].
  Widget buildBodyFrame(Widget content) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(40),
          child: content,
        ),
      ),
    );
  }
}
