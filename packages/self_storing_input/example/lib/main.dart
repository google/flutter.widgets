// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_storing_input/self_storing_input.dart';
import 'package:url_launcher/url_launcher.dart';

class Fields {
  static const String phrase = 'phrase';
  static const String paragraph = 'paragraph';
  static const String tristate = 'tristate';
  static const String twostate = 'twostate';
  static const String unselectableRadioGroup = 'unselectableRadioGroup';
  static const String radioGroup = 'radioGroup';
}

class _DemoSaver with ChangeNotifier implements Saver<String> {
  Map<String, dynamic> storage = {};
  bool failSaving = false;
  Duration delay = const Duration(milliseconds: 100);

  @override
  Future<T> load<T>(String itemKey) async {
    // This delay is for demo purposes.
    await Future.delayed(delay);
    return storage[itemKey];
  }

  @override
  OperationResult validate<T>(String itemKey, T value) {
    if (itemKey == Fields.phrase && (value?.toString()?.length ?? 0) % 2 == 1) {
      return OperationResult.error('Value should have even number of letters.');
    }
    return OperationResult.success();
  }

  @override
  Future<OperationResult> save<T>(String itemKey, T value) async {
    // This delay is for demo purposes.
    await Future.delayed(delay);
    if (failSaving) {
      return OperationResult.error(
          'Failed to save the value, for demo purposes.');
    }
    storage[itemKey] = value;
    notifyListeners();
    return OperationResult.success();
  }
}

void main() {
  runApp(Demo());
}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  OverlayController _controller = OverlayController();
  final _DemoSaver _saver = _DemoSaver();

  @override
  void initState() {
    _saver.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: () async {
          _controller.close();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: ListTileTheme(
              contentPadding: EdgeInsets.all(0),
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('SELF_STORING_INPUT\nDEMO', buildDemoHeader()),
                    _section('Demo Parameters', buildDemoParameters()),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('Self Storing Input Widgets', buildDemo()),
                        if (_saver.storage.isNotEmpty)
                          _section('Storage Content', buildStorageObserver()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _right(List<Widget> widgets) {
    return Padding(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
      padding: EdgeInsets.only(left: 20),
    );
  }

  Widget _section(String header, List<Widget> children) {
    return Container(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          ),
          SizedBox(height: 20),
          _right(children),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> buildDemoHeader() {
    return [
      TextButton(
        onPressed: () async => await launch(
            'https://github.com/google/flutter.widgets/tree/master/packages/self_storing_input/example'),
        child: Text(
          'Source Code',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ];
  }

  List<Widget> buildDemoParameters() {
    return [
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Fail the save operation'),
        value: _saver.failSaving,
        onChanged: (v) => setState(() => _saver.failSaving = v),
      ),
      SizedBox(height: 10),
      TextFormField(
        onChanged: (v) =>
            setState(() => _saver.delay = Duration(milliseconds: int.parse(v))),
        initialValue: _saver.delay.inMilliseconds.toString(),
        keyboardType: TextInputType.number,
        decoration:
            InputDecoration(labelText: 'Delay time for the save operation, ms'),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      )
    ];
  }

  List<Widget> buildDemo() {
    return [
      Text('${Fields.phrase}:'),
      SelfStoringText(
        Fields.phrase,
        overlayController: _controller,
        saver: _saver,
      ),
      SizedBox(height: 20),
      Text('${Fields.paragraph}:'),
      SelfStoringText(
        Fields.paragraph,
        overlayController: _controller,
        saver: _saver,
        style: SelfStoringTextStyle(
          overlayStyle: OverlayStyle.forTextEditor(height: 130),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ),
      SizedBox(height: 20),
      Text('checkboxes:'),
      SelfStoringCheckbox(
        Fields.tristate,
        saver: _saver,
        overlayController: _controller,
        title: Text(Fields.tristate),
      ),
      SizedBox(height: 20),
      SelfStoringCheckbox(
        Fields.twostate,
        saver: _saver,
        overlayController: _controller,
        title: Text(Fields.twostate),
        tristate: false,
      ),
      SizedBox(height: 40),
      Text('${Fields.unselectableRadioGroup}:'),
      SelfStoringRadioGroup(
        Fields.unselectableRadioGroup,
        saver: _saver,
        isUnselectable: true,
        overlayController: _controller,
        items: {1: 'One', 2: 'Two', 3: 'Three'},
      ),
      SizedBox(height: 40),
      Text('${Fields.radioGroup}:'),
      SelfStoringRadioGroup(
        Fields.radioGroup,
        saver: _saver,
        overlayController: _controller,
        items: {1: 'One', 2: 'Two', 3: 'Three'},
      ),
    ];
  }

  List<Widget> buildStorageObserver() {
    return [
      for (var id in _saver.storage.keys) Text('$id: ${_saver.storage[id]}'),
    ];
  }
}
