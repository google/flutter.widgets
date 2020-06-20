// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/self_storing_input.dart';
import 'package:url_launcher/url_launcher.dart';

class Fields {
  static const String phrase = 'phrase';
  static const String paragraph = 'paragraph';
}

class _DemoSaver with ChangeNotifier implements Saver {
  Map<String, dynamic> storage = {};
  bool _savingFailed = false;

  @override
  Future<T> load<T>(Object address) async {
    await Future.delayed(Duration(milliseconds: 500));
    return storage[address];
  }

  @override
  OperationResult validate<T>(Object address, T value) {
    if (address == Fields.phrase &&
        value is String &&
        (value?.toString()?.length ?? 0) % 2 == 1) {
      return OperationResult.error('Value should have even number of letters.');
    }
    return OperationResult.success();
  }

  @override
  Future<OperationResult> save<T>(Object address, T value) async {
    _savingFailed = !_savingFailed;
    await Future.delayed(Duration(milliseconds: 500));
    if (_savingFailed) {
      return OperationResult.error(
          'This is a very long error massage to demonstrate '
          'how the component handles saving failures. For demo purposes '
          'every second saving will fail. A real '
          'message can be like this: "Unfortunately '
          'we could not save the value to the storage. '
          'Check your internet connection and try again. '
          'Contact us if the problem persists."');
    }
    storage[address] = value;
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
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELF_STORING_INPUT DEMO'),
                  SizedBox(height: 50),
                  ...buildDemo(),
                  SizedBox(height: 50),
                  FlatButton(
                    onPressed: () async => await launch(
                        'https://github.com/google/flutter.widgets/tree/master/packages/self_storing_input/example'),
                    child: Text(
                      'Source Code',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _right(Widget widget) {
    return Padding(child: widget, padding: EdgeInsets.only(left: 20));
  }

  List<Widget> buildDemo() {
    return [
      Text('${Fields.phrase}:'),
      _right(SelfStoringText(
        Fields.phrase,
        overlayController: _controller,
        saver: _saver,
      )),
      SizedBox(height: 20),
      Text('${Fields.paragraph}:'),
      _right(SelfStoringText(
        Fields.paragraph,
        overlayController: _controller,
        saver: _saver,
        style: SelfStoringTextStyle(
          overlayHeight: 130,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      )),
      SizedBox(height: 60),
      if (_saver.storage.isNotEmpty) Text('STORAGE CONTENT:'),
      SizedBox(height: 20),
      for (var id in _saver.storage.keys)
        _right(Text('$id: ${_saver.storage[id]}')),
    ];
  }
}
