// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:collection';

import 'package:flutter/material.dart';

import 'visibility_detector.dart';

const String title = 'VisibilityDetector Demo';

/// The height of each row of the pseudo-table of [VisibilityDetector] widgets.
const double kRowHeight = 75;

/// The external padding around each row of the pseudo-table.
const double kRowPadding = 5;

/// The internal padding for each cell of the pseudo-table.
const double kCellPadding = 10;

/// The external padding around the widgets in the visibility report section.
const double kReportPadding = 5;

/// The height of the visibility report.
const double kReportHeight = 200;

/// The [Key] to the main [ListView] widget.
final mainListKey = Key('MainList');

/// Returns the [Key] to the [VisibilityDetector] widget in each cell of the
/// pseudo-table.
Key cellKey(int row, int col) => Key('Cell-${row}-${col}');

/// A callback to be invoked by the [VisibilityDetector.onVisibilityChanged]
/// callback.  We use the extra level of indirection to allow widget tests to
/// reuse this demo app with a different callback.
final visibilityListeners =
    <void Function(RowColumn rc, VisibilityInfo info)>[];

void main() {
  return runApp(VisibilityDetectorDemo());
}

/// The root widget for the demo app.
class VisibilityDetectorDemo extends StatelessWidget {
  const VisibilityDetectorDemo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VisibilityDetectorDemoPage(),
    );
  }
}

/// The main page [VisibilityDetectorDemo].
class VisibilityDetectorDemoPage extends StatefulWidget {
  const VisibilityDetectorDemoPage({Key key}) : super(key: key);

  @override
  VisibilityDetectorDemoPageState createState() =>
      VisibilityDetectorDemoPageState();
}

class VisibilityDetectorDemoPageState
    extends State<VisibilityDetectorDemoPage> {
  /// Whether the pseudo-table should be shown.
  bool _tableShown = true;

  /// Toggles the visibility of the pseudo-table of [VisibilityDetector] widgets.
  void _toggleTable() {
    setState(() {
      _tableShown = !_tableShown;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Our pseudo-table of [VisibilityDetector] widgets.  We want to scroll both
    // vertically and horizontally, so we'll implement it as a [ListView] of
    // [ListView]s.
    final table = !_tableShown
        ? null
        : ListView.builder(
            key: mainListKey,
            scrollDirection: Axis.vertical,
            itemExtent: kRowHeight,
            itemBuilder: (BuildContext context, int rowIndex) {
              return DemoPageRow(rowIndex: rowIndex);
            },
          );

    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      floatingActionButton: FloatingActionButton(
        shape: const Border(),
        onPressed: _toggleTable,
        child: _tableShown ? const Text('Hide') : const Text('Show'),
      ),
      body: Column(
        children: <Widget>[
          _tableShown ? Expanded(child: table) : Spacer(),
          VisibilityReport(title: 'Visibility'),
        ],
      ), // Column
    ); // Scaffold
  }
}

/// An individual row for the pseudo-table of [VisibilityDetector] widgets.
class DemoPageRow extends StatelessWidget {
  DemoPageRow({Key key, this.rowIndex}) : super(key: key);

  final int rowIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(kRowPadding),
      itemBuilder: (BuildContext context, int columnIndex) {
        return DemoPageCell(rowIndex: rowIndex, columnIndex: columnIndex);
      }, // itemBuilder
    ); // ListView.builder
  }
}

/// An individual cell for the pseudo-table of [VisibilityDetector] widgets.
class DemoPageCell extends StatelessWidget {
  DemoPageCell({Key key, this.rowIndex, this.columnIndex})
      : _cellName = 'Item ${rowIndex}-${columnIndex}',
        _backgroundColor = ((rowIndex + columnIndex) % 2 == 0)
            ? Colors.pink[200]
            : Colors.yellow[200],
        super(key: key);

  final int rowIndex;
  final int columnIndex;

  /// The text to show for the cell.
  final String _cellName;

  final Color _backgroundColor;

  /// [VisibilityDetector] callback for when the visibility of the widget
  /// changes.  Triggers the [visibilityListeners] callbacks.
  void _handleVisibilityChanged(VisibilityInfo info) {
    for (final listener in visibilityListeners) {
      listener(RowColumn(rowIndex, columnIndex), info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: cellKey(rowIndex, columnIndex),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        decoration: BoxDecoration(color: _backgroundColor),
        padding: const EdgeInsets.all(kCellPadding),
        alignment: Alignment.center,
        child: Text(_cellName, style: Theme.of(context).textTheme.display1),
      ), // Container
    ); // VisibilityDetector
  }
}

/// A widget that lists the reported visibility percentages of the
/// [VisibilityDetector] widgets on the page.
class VisibilityReport extends StatelessWidget {
  const VisibilityReport({Key key, this.title}) : super(key: key);

  /// The text to use for the heading of the report.
  final String title;

  @override
  Widget build(BuildContext context) {
    final headingTextStyle =
        Theme.of(context).textTheme.title.copyWith(color: Colors.white);

    final heading = Container(
      padding: const EdgeInsets.all(kReportPadding),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(color: Colors.black),
      child: Text(title, style: headingTextStyle),
    );

    final grid = Container(
      padding: const EdgeInsets.all(kReportPadding),
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: const SizedBox(
        height: kReportHeight,
        child: const VisibilityReportGrid(),
      ),
    );

    return Column(children: <Widget>[heading, grid]);
  }
}

/// The portion of [VisibilityReport] that shows data.
class VisibilityReportGrid extends StatefulWidget {
  const VisibilityReportGrid({Key key}) : super(key: key);

  @override
  VisibilityReportGridState createState() => VisibilityReportGridState();
}

class VisibilityReportGridState extends State<VisibilityReportGrid> {
  /// Maps [row, column] indices to the visibility percentage of the
  /// corresponding [VisibilityDetector] widget.
  final _visibilities = SplayTreeMap<RowColumn, double>();

  /// The [Text] widgets used to fill our [GridView].
  List<Text> _reportItems;

  /// See [State.initState].  Adds a callback to [visibilityListeners] to update
  /// the visibility report with the widget's visibility.
  @override
  initState() {
    super.initState();

    visibilityListeners.add(_update);
    assert(visibilityListeners.contains(_update));
  }

  @override
  dispose() {
    visibilityListeners.remove(_update);

    super.dispose();
  }

  /// Callback added to [visibilityListeners] to update the state.
  void _update(RowColumn rc, VisibilityInfo info) {
    setState(() {
      if (info.visibleFraction == 0) {
        _visibilities.remove(rc);
      } else {
        _visibilities[rc] = info.visibleFraction;
      }

      // Invalidate `_reportItems` so that we regenerate it lazily.
      _reportItems = null;
    });
  }

  /// Populates [_reportItems].
  List<Text> _generateReportItems() {
    final entries = _visibilities.entries;
    final items = <Text>[];

    for (final MapEntry<RowColumn, double> i in entries) {
      final String visiblePercentage = (i.value * 100).toStringAsFixed(1);
      items.add(Text('${i.key}: ${visiblePercentage}%'));
    }

    // It's easier to read cells down than across, so sort by columns instead of
    // by rows.
    final int tailIndex = items.length - items.length ~/ 3;
    final int midIndex = tailIndex - tailIndex ~/ 2;
    final head = items.getRange(0, midIndex);
    final mid = items.getRange(midIndex, tailIndex);
    final tail = items.getRange(tailIndex, items.length);
    return collate([head, mid, tail]).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_reportItems == null) {
      _reportItems = _generateReportItems();
    }

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 8,
      padding: const EdgeInsets.all(5),
      children: _reportItems,
    );
  }
}

/// A class for storing a [row, column] pair.
class RowColumn extends Comparable<RowColumn> {
  RowColumn(this.row, this.column);

  final int row;
  final int column;

  bool operator ==(dynamic other) {
    if (other is RowColumn) {
      return row == other.row && column == other.column;
    }
    return false;
  }

  int get hashCode => hashValues(row, column);

  /// See [Comparable.compareTo].  Sorts [RowColumn] objects in row-major order.
  @override
  int compareTo(RowColumn other) {
    if (row < other.row) {
      return -1;
    } else if (row > other.row) {
      return 1;
    }

    if (column < other.column) {
      return -1;
    } else if (column > other.column) {
      return 1;
    }

    return 0;
  }

  @override
  String toString() {
    return '[${row}, ${column}]';
  }
}

/// Returns an [Iterable] containing the nth element (if it exists) of every
/// [Iterable] in `iterables` in sequence.
///
/// For example, `collate([[1, 4, 7], [2, 5, 8, 9], [3, 6]])` would return a
/// a sequence [1, 2, 3, 4, 5, 6, 7, 8, 9].
Iterable<T> collate<T>(Iterable<Iterable<T>> iterables) sync* {
  final iterators = iterables.map((e) => e.iterator).toList(growable: false);
  while (true) {
    int numEmpty = 0;
    for (final i in iterators) {
      if (i.moveNext()) {
        yield i.current;
        continue;
      }

      numEmpty += 1;
      if (numEmpty == iterators.length) {
        // All iterators are at their ends.
        return;
      }
    }
  }
}
