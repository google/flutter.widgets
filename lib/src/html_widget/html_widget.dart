// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

/// Limited support for rendering HTML as flutter widgets.
///
/// TODO: adopt parsing pattern found in `flutter_markdown`.
library flutter_html;

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

/// Called with the [href] of an anchor tag.
typedef LinkCallback = void Function(String href);

/// A Widget for displaying HTML in flutter.
class HtmlView extends StatefulWidget {
  /// A valid html template string.
  final String content;

  /// A callback to fire when a user taps an anchor tag.
  final LinkCallback onTapLink;

  HtmlView({@required this.content, this.onTapLink});

  @override
  State<StatefulWidget> createState() => _HtmlViewState();

  /// Finds the parent [HtmlView] for the current context.
  static _HtmlViewState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<_HtmlViewState>());
  }
}

class _HtmlViewState extends State<HtmlView> {
  bool _didFailToParse = false;
  dom.Node _document;

  @override
  void initState() {
    _parseContent();
    super.initState();
  }

  @override
  void didUpdateWidget(HtmlView oldState) {
    if (oldState.content != widget.content) {
      _didFailToParse = false;
      _parseContent();
    }
    super.didUpdateWidget(oldState);
  }

  /// Signals failure in building HTML.
  void failToBuild() {
    Timer.run(() => setState(() {
          _didFailToParse = true;
        }));
  }

  /// Fires the [onTapLink] callback with [href].
  void onTapLink(String href) {
    if (widget.onTapLink != null) {
      widget.onTapLink(href);
    }
  }

  void _parseContent() {
    try {
      var document = parse(widget.content);
      setState(() => _document = document.body);
    } on Exception catch (_) {
      /// Parse exceptions are not clearly documented.
      setState(() => _didFailToParse = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// If parsing fails, fallback to the plaintext
    if (_didFailToParse) {
      return Text(widget.content);
    }
    return HtmlBlockViewBuilder(_document.nodes);
  }
}

/// Builds an HTML widget from a list of [dom.Node]
///
/// Used to build a child list into a single Widget for compatability with
/// flutter.  If there is only a single child, the widgets will not be wrapped
/// in another block.
class HtmlBlockViewBuilder extends StatelessWidget {
  final List<dom.Node> nodes;

  HtmlBlockViewBuilder(this.nodes);

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return Container(height: 0.0, width: 0.0);
    }
    if (nodes.length == 1) {
      return HtmlViewBuilder(node: nodes.single);
    }
    return Column(
      children: nodes.map((node) => HtmlViewBuilder(node: node)).toList(),
    );
  }
}

/// Builds an HTML widget from a [dom.Node].
class HtmlViewBuilder extends StatelessWidget {
  final dom.Node node;

  HtmlViewBuilder({@required this.node});

  @override
  Widget build(BuildContext context) {
    if (node is dom.Text) {
      return HtmlText(node);
    }
    if (node is dom.Element) {
      var name = (node as dom.Element).localName;
      switch (name) {
        case 'div':
          return HtmlBlockViewBuilder(node.nodes);
        case 'br':
          return HtmlBreak(node);
        case 'table':
          return HtmlTable(node);
        case 'b':
          return HtmlBold(node);
        case 'u':
          return HtmlUnderline(node);
        case 'a':
          return HtmlLink(node);
        case 'font':
          return HtmlFontTag(node);
        case 'hr':
          return HtmlHr(node);
        default:

          /// Any other tags cannot be built by this widget, and will cause the
          /// plaintext to show.
          HtmlView.of(context).failToBuild();
      }
    }
    return Container();
  }
}

/// Builds a [Text] widget from a [dom.Text] element.
class HtmlText extends StatelessWidget {
  final dom.Text text;

  HtmlText(this.text);

  @override
  Widget build(BuildContext context) => Text(text.data);
}

/// Builds a link from a template <a href="">Some Text</a> tag.
class HtmlLink extends StatelessWidget {
  final dom.Element element;

  HtmlLink(this.element);

  @override
  Widget build(BuildContext context) {
    assert(
        element.localName == 'a', 'Expected <a> tag, instead found $element');

    var href = element.attributes['href'];

    return FlatButton(
        child: Text(
          element.text ?? 'Link',
          style: TextStyle(color: Colors.blue[300]),
        ),
        onPressed: () => HtmlView.of(context).onTapLink(href));
  }
}

/// Builds a table from a template <table>...</table> tag.
///
/// TODO: support table header tags.
/// TODO: allow table customization.
class HtmlTable extends StatelessWidget {
  final dom.Element element;

  HtmlTable(this.element);
  @override
  Widget build(BuildContext context) {
    assert(element.localName == 'table',
        'Expected <table>, instead found $element');

    var body = element.children
        .firstWhere((el) => el.localName == 'tbody', orElse: () => null);

    List<TableRow> children;
    if (body != null) {
      children = body.children.map(_buildRow).toList();
    } else {
      children = const [];
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: children,
    );
  }

  /// Builds a table row from  a <tr> tag.
  TableRow _buildRow(dom.Element row) {
    assert(row.localName == 'tr', 'Expected <tr>, instead found $row');

    return TableRow(children: row.children.map(_buildCell).toList());
  }

  /// Builds a table cell from a <td> tag.
  TableCell _buildCell(dom.Element cell) {
    assert(cell.localName == 'td', 'Expected <td>, instead found $cell');
    return TableCell(child: HtmlBlockViewBuilder(cell.nodes));
  }
}

/// Builds a block element from a template <div>...</div> tag.
class HtmlDiv extends StatelessWidget {
  final dom.Element element;

  HtmlDiv(this.element);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          element.nodes.map((node) => HtmlViewBuilder(node: node)).toList(),
    );
  }
}

/// Applies an underline to all child elements from a template <u> tag.
class HtmlUnderline extends StatelessWidget {
  final dom.Element element;

  HtmlUnderline(this.element);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context)
          .style
          .copyWith(decoration: TextDecoration.underline),
      child: HtmlBlockViewBuilder(element.nodes),
    );
  }
}

/// Builds a divider from a <hr> tag.
class HtmlHr extends StatelessWidget {
  final dom.Element element;

  HtmlHr(this.element);

  @override
  Widget build(BuildContext context) {
    return Divider();
  }
}

/// Applies boldface to all child elements from a template <b> tag.
class HtmlBold extends StatelessWidget {
  final dom.Element element;

  HtmlBold(this.element);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context)
          .style
          .copyWith(fontWeight: FontWeight.bold),
      child: HtmlBlockViewBuilder(element.nodes),
    );
  }
}

/// Creates a line break from a template <br/> tag.
class HtmlBreak extends StatelessWidget {
  final dom.Element element;

  HtmlBreak(this.element);

  @override
  Widget build(BuildContext context) {
    assert(element.localName == 'br');
    return Container(height: 8.0);
  }
}

/// Applies new font style to child elements from a <font color="...">
/// tag.
///
/// TODO: support color strings and font face attributes.
class HtmlFontTag extends StatelessWidget {
  final dom.Element element;

  HtmlFontTag(this.element);

  @override
  Widget build(BuildContext context) {
    assert(
        element.localName == 'font', 'Expected <font>, instead found $element');

    Color color;
    try {
      var raw = int.parse(element.attributes['color'], radix: 16);
      color = Color.fromRGBO(raw >> 32, (raw >> 16) & 0xFF, raw & 0xFF, 1.0);
    } on FormatException catch (_) {
      color = Colors.black;
    }
    return DefaultTextStyle(
      style: TextStyle(color: color),
      child: HtmlBlockViewBuilder(element.nodes),
    );
  }
}
