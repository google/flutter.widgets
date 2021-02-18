// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

const String title = 'VisibilityDetector Demo';

/// The width of each cell of our pseudo-table of [VisibilityDetector] widgets.
const double cellWidth = 125;

//// The height of each cell of our pseudo-table.
const double cellHeight = _rowHeight - 2 * _rowPadding;

/// The height of each row of the pseudo-table.  This includes [_rowPadding] on
/// top and bottom.
const double _rowHeight = 75;

/// The external padding around each row of the pseudo-table.
const double _rowPadding = 5;

/// The internal padding for each cell of the pseudo-table.
const double _cellPadding = 10;

/// The external padding around the widgets in the visibility report section.
const double _reportPadding = 5;

/// The height of the visibility report.
const double _reportHeight = 200;

/// The [Key] to the main [ListView] widget.
const mainListKey = Key('MainList');

/// Returns the [Key] to the [VisibilityDetector] widget in each cell of the
/// pseudo-table.
Key cellKey(int row, int col) => Key('Cell-$row-$col');

/// A callback to be invoked by the [VisibilityDetector.onVisibilityChanged]
/// callback.  We use the extra level of indirection to allow widget tests to
/// reuse this demo app with a different callback.
final visibilityListeners =
    <void Function(RowColumn rc, VisibilityInfo info)>[];

void main() => runApp(const VisibilityDetectorDemo());

/// The root widget for the demo app.
class VisibilityDetectorDemo extends StatelessWidget {
  const VisibilityDetectorDemo({Key? key}) : super(key: key);

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
  const VisibilityDetectorDemoPage({Key? key}) : super(key: key);

  @override
  VisibilityDetectorDemoPageState createState() =>
      VisibilityDetectorDemoPageState();
}

class VisibilityDetectorDemoPageState
    extends State<VisibilityDetectorDemoPage> {
  /// Whether the pseudo-table should be shown.
  bool _tableShown = true;

  /// Whether to use slivers.
  bool _useSlivers = false;

  /// Toggles the visibility of the pseudo-table of [VisibilityDetector]
  /// widgets.
  void _toggleTable() {
    setState(() {
      _tableShown = !_tableShown;
    });
  }

  /// Toggles between RenderBox and RenderSliver widgets.
  void _toggleSlivers() {
    setState(() {
      _useSlivers = !_useSlivers;
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
            itemExtent: _rowHeight,
            itemBuilder: (BuildContext context, int rowIndex) {
              return DemoPageRow(rowIndex: rowIndex, useSlivers: _useSlivers);
            },
          );

    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            shape: const Border(),
            onPressed: _toggleSlivers,
            child: _useSlivers
                ? const Text('RenderBox')
                : const Text('RenderSliver'),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            shape: const Border(),
            onPressed: _toggleTable,
            child: _tableShown ? const Text('Hide') : const Text('Show'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _tableShown ? Expanded(child: table!) : const Spacer(),
          VisibilityReport(
              title:
                  'Visibility (${_useSlivers ? "RenderSliver" : "RenderBox"})'),
        ],
      ),
    );
  }
}

/// An individual row for the pseudo-table of [VisibilityDetector] widgets.
class DemoPageRow extends StatelessWidget {
  const DemoPageRow(
      {Key? key, required this.rowIndex, required this.useSlivers})
      : super(key: key);

  final int rowIndex;
  final bool useSlivers;

  @override
  Widget build(BuildContext context) {
    if (useSlivers) {
      return CustomScrollView(scrollDirection: Axis.horizontal, slivers: [
        for (var columnIndex = 0; columnIndex < 20; columnIndex++)
          SliverPadding(
            padding: const EdgeInsets.all(_rowPadding),
            sliver: SliverToBoxAdapter(
              child: DemoPageCell(rowIndex: rowIndex, columnIndex: columnIndex),
            ),
          ),
      ]);
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int columnIndex) {
        return Padding(
          padding: const EdgeInsets.all(_rowPadding),
          child: DemoPageCell(rowIndex: rowIndex, columnIndex: columnIndex),
        );
      },
    );
  }
}

/// An individual cell for the pseudo-table of [VisibilityDetector] widgets.
class DemoPageCell extends StatelessWidget {
  DemoPageCell({Key? key, required this.rowIndex, required this.columnIndex})
      : _cellName = 'Item $rowIndex-$columnIndex',
        _backgroundColor = ((rowIndex + columnIndex) % 2 == 0)
            ? Colors.pink[200]
            : Colors.yellow[200],
        super(key: key);

  final int rowIndex;
  final int columnIndex;

  /// The text to show for the cell.
  final String _cellName;

  final Color? _backgroundColor;

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
        width: cellWidth,
        decoration: BoxDecoration(color: _backgroundColor),
        padding: const EdgeInsets.all(_cellPadding),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(_cellName, style: Theme.of(context).textTheme.headline4),
        ),
      ),
    );
  }
}

/// A widget that lists the reported visibility percentages of the
/// [VisibilityDetector] widgets on the page.
class VisibilityReport extends StatelessWidget {
  const VisibilityReport({Key? key, required this.title}) : super(key: key);

  /// The text to use for the heading of the report.
  final String title;

  @override
  Widget build(BuildContext context) {
    final headingTextStyle =
        Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white);

    final heading = Container(
      padding: const EdgeInsets.all(_reportPadding),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(color: Colors.black),
      child: Text(title, style: headingTextStyle),
    );

    final grid = Container(
      padding: const EdgeInsets.all(_reportPadding),
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: const SizedBox(
        height: _reportHeight,
        child: VisibilityReportGrid(),
      ),
    );

    return Column(children: <Widget>[heading, grid]);
  }
}

/// The portion of [VisibilityReport] that shows data.
class VisibilityReportGrid extends StatefulWidget {
  const VisibilityReportGrid({Key? key}) : super(key: key);

  @override
  VisibilityReportGridState createState() => VisibilityReportGridState();
}

class VisibilityReportGridState extends State<VisibilityReportGrid> {
  /// Maps [row, column] indices to the visibility percentage of the
  /// corresponding [VisibilityDetector] widget.
  final _visibilities = SplayTreeMap<RowColumn, double>();

  /// The [Text] widgets used to fill our [GridView].
  List<Text>? _reportItems;

  /// See [State.initState].  Adds a callback to [visibilityListeners] to update
  /// the visibility report with the widget's visibility.
  @override
  void initState() {
    super.initState();

    visibilityListeners.add(_update);
    assert(visibilityListeners.contains(_update));
  }

  @override
  void dispose() {
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

    for (final i in entries) {
      final visiblePercentage = (i.value * 100).toStringAsFixed(1);
      items.add(Text('${i.key}: $visiblePercentage%'));
    }

    // It's easier to read cells down than across, so sort by columns instead of
    // by rows.
    final tailIndex = items.length - items.length ~/ 3;
    final midIndex = tailIndex - tailIndex ~/ 2;
    final head = items.getRange(0, midIndex);
    final mid = items.getRange(midIndex, tailIndex);
    final tail = items.getRange(tailIndex, items.length);
    return collate([head, mid, tail]).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    _reportItems ??= _generateReportItems();

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 8,
      padding: const EdgeInsets.all(5),
      children: _reportItems!,
    );
  }
}

/// A class for storing a [row, column] pair.
class RowColumn extends Comparable<RowColumn> {
  RowColumn(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(dynamic other) {
    if (other is RowColumn) {
      return row == other.row && column == other.column;
    }
    return false;
  }

  @override
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
    return '[$row, $column]';
  }
}

/// Returns an [Iterable] containing the nth element (if it exists) of every
/// [Iterable] in `iterables` in sequence.
///
/// Unlike [zip](https://pub.dev/documentation/quiver/latest/quiver.iterables/zip.html),
/// returns a single sequence and continues until *all* [Iterable]s are
/// exhausted.
///
/// For example, `collate([[1, 4, 7], [2, 5, 8, 9], [3, 6]])` would return a
/// sequence `1, 2, 3, 4, 5, 6, 7, 8, 9`.
@visibleForTesting
Iterable<T> collate<T>(Iterable<Iterable<T>> iterables) sync* {
  assert(iterables != null);

  final iterators = [for (final iterable in iterables) iterable.iterator];
  if (iterators.isEmpty) {
    return;
  }

  // ignore: literal_only_boolean_expressions, https://github.com/dart-lang/linter/issues/453
  while (true) {
    var exhaustedCount = 0;
    for (final i in iterators) {
      if (i.moveNext()) {
        yield i.current;
        continue;
      }

      exhaustedCount += 1;
      if (exhaustedCount == iterators.length) {
        // All iterators are at their ends.
        return;
      }
    }
  }
}
