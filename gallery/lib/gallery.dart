// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:gallery/src/linked_scroll_controller_page.dart';
import 'package:gallery/src/tagged_text_page.dart';
import 'package:gallery/src/html_widget_page.dart' as html_latency;

/// Router to all widgets inside the gallery app.
///
/// The app will start with a list showing the `title` field of each
/// [_GalleryPage] in `pages`.  Tapping into an item will build the
/// `pageBuilder` for that page on a new route.
class Gallery extends StatefulWidget {
  final List<_GalleryPage> pages = <_GalleryPage>[]
    ..addAll(_GalleryPage.fromMap(html_latency.nameToTestData))
    ..add(new _GalleryPage(
      title: 'Tagged Text',
      pageBuilder: (context) => new TaggedTextPage(),
    ))
    ..add(new _GalleryPage(
      title: 'Linked Scrollables',
      pageBuilder: (context) => new LinkedScrollablesPage(),
    ));

  @override
  State<StatefulWidget> createState() {
    return new _GalleryState();
  }
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Widgets by Google',
      home: new Scaffold(
        appBar: new AppBar(title: new Text('Flutter Widgets by Google')),
        body: new Builder(builder: (context) => _buildWidgetList(context)),
      ),
    );
  }

  Widget _buildWidgetList(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (context, i) {
        return new ListTile(
          title: new Text(widget.pages[i].title),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: widget.pages[i].pageBuilder));
          },
        );
      },
      itemCount: widget.pages.length,
    );
  }
}

/// Wrapper leading to each page of the gallery app.
///
/// Each instance showcases a single widget's functionality.  `title` is the
/// title shown in the top-level view of the app.  `pageBuilder` is a
/// [WidgetBuilder] that creates the content to show in that page of the app.
///
/// Note that this is a plain-old Dart object, not a widget.  It defines data
/// that the [Gallery] uses to create widgets, one for the entry at the top
/// level list in the app and another for the detail view in each widget's
/// demo page.
class _GalleryPage {
  final String title;
  final WidgetBuilder pageBuilder;

  _GalleryPage({@required this.title, @required this.pageBuilder}) {
    assert(title != null);
    assert(pageBuilder != null);
  }

  static Iterable<_GalleryPage> fromMap(
      Map<String, WidgetBuilder> nameToTestData) {
    return nameToTestData.keys.map((key) =>
        new _GalleryPage(title: key, pageBuilder: nameToTestData[key]));
  }
}
