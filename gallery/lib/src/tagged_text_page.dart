// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

/// Gallery page for demoing the [TaggedText].
class TaggedTextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Semantic tagged text')),
      body: Center(
        child: TaggedText(
          content:
              '<greeting>Hello</greeting>, my name is <name>Buster</name>!',
          tagToTextSpanBuilder: {
            'greeting': (text) => TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            'name': (text) => TextSpan(
                text: text,
                style: const TextStyle(decoration: TextDecoration.underline)),
          },
          style: Theme.of(context).textTheme.body1,
        ),
      ),
    );
  }
}
