// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import '../primitives/message_overlay.dart';
import '../primitives/overlay_builder.dart';
import 'shared_state.dart';

/// The checkbox that saves entered value and
/// shows error message in case of failure.
class CustomCheckbox extends StatefulWidget {
  final SharedState state;

  const CustomCheckbox(this.state);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool? _localValue;
  OverlayEntry? _overlay;

  @override
  void initState() {
    _localValue = widget.state.storedValue;
    widget.state.overlayController.addListener(_closeOverlay);
    super.initState();
  }

  @override
  void dispose() {
    widget.state.overlayController.removeListener(_closeOverlay);
    super.dispose();
  }

  void _showOverlay() {
    widget.state.overlayController.close();
    _overlay = _buildOverlay(context);
    Overlay.of(context)!.insert(_overlay!);
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
    setState(() {});
  }

  OverlayEntry _buildOverlay(BuildContext context) {
    return createOverlayInTheMiddle(
      MessageOverlay(
        message: widget.state.operationResult.error!,
        style: widget.state.style.overlayStyle,
        closeIconSize: widget.state.style.closeIconSize,
        overlayController: widget.state.overlayController,
      ),
      context,
      widget.state.style.overlayStyle,
    );
  }

  void _onValueChanged(bool? value) async {
    _localValue = value;
    widget.state.isSaving = true;
    setState(() {});
    widget.state.operationResult =
        await widget.state.saver.save(widget.state.itemKey, _localValue);
    if (widget.state.operationResult.isSuccess) {
      widget.state.storedValue = _localValue;
    } else {
      _localValue = widget.state.storedValue;
      _showOverlay();
    }
    widget.state.isSaving = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var isEnabled = !widget.state.isSaving && _overlay == null;

    return Checkbox(
      onChanged: isEnabled ? _onValueChanged : null,
      value: _localValue,
      tristate: widget.state.tristate,
      activeColor: Theme.of(context).colorScheme.secondary,
    );
  }
}
