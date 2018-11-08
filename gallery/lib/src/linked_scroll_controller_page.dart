// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

/// Gallery page for demoing the [LinkedScrollControllerGroup].
class LinkedScrollablesPage extends StatefulWidget {
  @override
  _LinkedScrollablesPageState createState() => _LinkedScrollablesPageState();
}

class _LinkedScrollablesPageState extends State<LinkedScrollablesPage> {
  LinkedScrollControllerGroup _controllers;
  ScrollController _letters;
  ScrollController _numbers;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _letters = _controllers.addAndGet();
    _numbers = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _letters.dispose();
    _numbers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('Linked Scrollables')),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              controller: _letters,
              children: <Widget>[
                _Tile('Hello A'),
                _Tile('Hello B'),
                _Tile('Hello C'),
                _Tile('Hello D'),
                _Tile('Hello E'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _numbers,
              children: <Widget>[
                _Tile('Hello 1'),
                _Tile('Hello 2'),
                _Tile('Hello 3'),
                _Tile('Hello 4'),
                _Tile('Hello 5'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String caption;

  _Tile(this.caption);

  @override
  Widget build(_) => Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        height: 250.0,
        child: Center(child: Text(caption)),
      );
}
