// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

const numberOfItems = 10000;
const minItemHeight = 20.0;
const maxItemHeight = 150.0;
const scrollDuration = Duration(seconds: 2);

/// Gallery page for [ScrollablePositionedList].
class ScrollablePositionedListPage extends StatefulWidget {
  const ScrollablePositionedListPage({Key key}) : super(key: key);

  @override
  _ScrollablePositionedListPageState createState() =>
      _ScrollablePositionedListPageState();
}

class _ScrollablePositionedListPageState
    extends State<ScrollablePositionedListPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<double> heights;
  List<Color> colors;
  bool reversed = false;
  double alignment = 0;

  @override
  void initState() {
    super.initState();
    final Random heightGenerator = Random(328902348);
    final Random colorGenerator = Random(42490823);
    heights = List<double>.generate(
        numberOfItems,
        (int _) =>
            heightGenerator.nextDouble() * (maxItemHeight - minItemHeight) +
            minItemHeight);
    colors = List<Color>.generate(
        numberOfItems,
        (int _) =>
            Color(colorGenerator.nextInt(pow(2, 32) - 1)).withOpacity(1));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Scrollable Positioned List')),
        body: Material(
          child: OrientationBuilder(
            builder: (context, orientation) => Column(
              children: <Widget>[
                Expanded(
                  child: list(orientation),
                ),
                positionsView,
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        scrollControlButtons,
                        jumpControlButtons,
                        alignmentControl,
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );

  Widget get alignmentControl => Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Text('Alignment: '),
          SizedBox(
            width: 200,
            child: Slider(
              value: alignment,
              onChanged: (double value) => setState(() => alignment = value),
            ),
          ),
        ],
      );

  Widget list(Orientation orientation) => ScrollablePositionedList.builder(
        itemCount: numberOfItems,
        itemBuilder: (context, index) => item(index, orientation),
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        reverse: reversed,
        scrollDirection: orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
      );

  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          int min;
          int max;
          if (positions.isNotEmpty) {
            min = positions
                .where((ItemPosition position) => position.itemTrailingEdge > 0)
                .reduce((ItemPosition min, ItemPosition position) =>
                    position.itemTrailingEdge < min.itemTrailingEdge
                        ? position
                        : min)
                .index;
            max = positions
                .where((ItemPosition position) => position.itemLeadingEdge < 1)
                .reduce((ItemPosition max, ItemPosition position) =>
                    position.itemLeadingEdge > max.itemLeadingEdge
                        ? position
                        : max)
                .index;
          }
          return Row(
            children: <Widget>[
              Expanded(child: Text('First Item: ${min ?? ''}')),
              Expanded(child: Text('Last Item: ${max ?? ''}')),
              const Text('Reversed: '),
              Checkbox(
                  value: reversed,
                  onChanged: (bool value) => setState(() {
                        reversed = value;
                      }))
            ],
          );
        },
      );

  Widget get scrollControlButtons => Row(
        children: <Widget>[
          const Text('scroll to'),
          scrollButton(0),
          scrollButton(5),
          scrollButton(10),
          scrollButton(100),
          scrollButton(1000),
        ],
      );

  Widget get jumpControlButtons => Row(
        children: <Widget>[
          const Text('jump to'),
          jumpButton(0),
          jumpButton(5),
          jumpButton(10),
          jumpButton(100),
          jumpButton(1000),
        ],
      );

  Widget scrollButton(int value) => GestureDetector(
        key: ValueKey<String>('Scroll$value'),
        onTap: () => scrollTo(value),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$value')),
      );

  Widget jumpButton(int value) => GestureDetector(
        key: ValueKey<String>('Jump$value'),
        onTap: () => jumpTo(value),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$value')),
      );

  void scrollTo(int index) => itemScrollController.scrollTo(
      index: index,
      duration: scrollDuration,
      curve: Curves.easeInOutCubic,
      alignment: alignment);

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: alignment);

  Widget item(int i, Orientation orientation) {
    return SizedBox(
      height: orientation == Orientation.portrait ? heights[i] : null,
      width: orientation == Orientation.landscape ? heights[i] : null,
      child: Container(
        color: colors[i],
        child: Center(
          child: Text('Item $i'),
        ),
      ),
    );
  }
}
