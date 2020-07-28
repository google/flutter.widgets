// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/src/self_storing_text/edit_button.dart';

import 'primitives/overlay.dart';
import 'primitives/saver.dart';
import 'primitives/the_progress_indicator.dart';
import 'self_storing_text/self_storing_text_style.dart';
import 'self_storing_text/shared_state.dart';

/// A widget to enter and store single or multiline text.
class SelfStoringText extends StatefulWidget {
  final Saver saver;
  final Object itemKey;
  final String emptyText;
  final OverlayController overlayController;
  final SelfStoringTextStyle style;

  SelfStoringText(
    this.itemKey, {
    Key key,
    this.saver = const NoOpSaver(),
    this.emptyText = '--',
    overlayController,
    this.style = const SelfStoringTextStyle(),
  })  : overlayController = overlayController ?? OverlayController(),
        super(key: key);

  @override
  _SelfStoringTextState createState() => _SelfStoringTextState();
}

class _SelfStoringTextState extends State<SelfStoringText> {
  SharedState _state;
  bool _isLoading = true;

  @override
  void initState() {
    _loadValue();
    super.initState();
  }

  @override
  void dispose() {
    _state.removeListener(_onSharedStateChange);
    super.dispose();
  }

  void _onSharedStateChange() => setState(() {});

  Future<void> _loadValue() async {
    var storedValue = await widget.saver.load<String>(widget.itemKey);
    _state = SharedState(
      storedValue: storedValue,
      overlayController: widget.overlayController,
      saver: widget.saver,
      itemKey: widget.itemKey,
      style: widget.style,
    )..addListener(_onSharedStateChange);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return theProgressIndicator;
    }

    var text = _state.storedValue;
    if (text == null || text.isEmpty) text = widget.emptyText;

    return Row(
      children: [
        Flexible(child: Text(text)),
        EditButton(_state),
      ],
    );
  }
}
