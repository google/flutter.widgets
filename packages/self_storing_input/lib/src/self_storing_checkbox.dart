// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/src/self_storing_checkbox/shared_state.dart';

import 'primitives/overlay.dart';
import 'primitives/saver.dart';
import 'primitives/the_progress_indicator.dart';
import 'self_storing_checkbox/custom_checkbox.dart';
import 'self_storing_checkbox/self_storing_checkbox_style.dart';

/// A widget to enter and store a boolean value.
class SelfStoringCheckbox<K> extends StatefulWidget {
  /// [Saver.validate] will not be invoked for [SelfStoringCheckbox].
  final Saver<K> saver;

  /// Key of the item to be provided to [saver].
  final K itemKey;
  final OverlayController overlayController;
  final SelfStoringCheckboxStyle style;

  /// If true this checkbox's value can be any one of true, false, or null.
  ///
  /// If tristate is false, a null value for this checkbox
  /// will be interpreted as false.
  /// See [Checkbox.tristate] for more.
  final bool tristate;

  /// The same as [CheckboxListTile.title].
  final Widget title;

  SelfStoringCheckbox(
    this.itemKey, {
    Key? key,
    saver,
    overlayController,
    this.tristate = true,
    Widget? title,
    this.style = const SelfStoringCheckboxStyle(),
  })  : overlayController = overlayController ?? OverlayController(),
        this.title = title ?? Container(width: 0, height: 0),
        this.saver = saver ?? NoOpSaver<K>(),
        super(key: key);

  @override
  _SelfStoringCheckboxState createState() => _SelfStoringCheckboxState();
}

class _SelfStoringCheckboxState extends State<SelfStoringCheckbox> {
  bool _isLoading = true;
  SharedState? _state;

  @override
  void initState() {
    _loadValue();
    super.initState();
  }

  @override
  void dispose() {
    _state!.removeListener(_onSharedStateChange);
    super.dispose();
  }

  void _onSharedStateChange() {
    setState(() {});
  }

  Future<void> _loadValue() async {
    var storedValue = await widget.saver.load<bool>(widget.itemKey);
    if (storedValue == null && !widget.tristate) storedValue = false;
    _state = SharedState(
      saver: widget.saver,
      itemKey: widget.itemKey,
      overlayController: widget.overlayController,
      style: widget.style,
      tristate: widget.tristate,
      storedValue: storedValue,
    )..addListener(_onSharedStateChange);
    _isLoading = false;
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return theProgressIndicator;

    return Row(
      children: [
        CustomCheckbox(_state!),
        widget.title,
        if (_state!.isSaving) theProgressIndicator,
      ],
    );
  }
}
