// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/src/primitives/message_overlay.dart';

import '../primitives/overlay_builder.dart';
import 'shared_state.dart';

/// Radio button that saves the radio group value using [state.saver]
/// and can be unchecked.
class CustomRadio extends StatelessWidget {
  final SharedState? state;
  final Object value;

  const CustomRadio(this.state, this.value);

  bool get isSelected => state!.selectedValue == value;

  @override
  Widget build(BuildContext context) {
    var isEnabled = !(state!.isSaving as bool) && state!.overlay == null;
    var iconSize = (Theme.of(context).iconTheme.size ?? 24);
    var icon = Icons.radio_button_unchecked;
    if (isSelected) {
      icon = state!.isUnselectable
          ? Icons.check_circle
          : Icons.radio_button_checked;
    }

    return GestureDetector(
      onTap: isEnabled ? () => _onTap(context) : null,
      child: Padding(
        padding: EdgeInsets.all(iconSize / 2),
        child: Icon(
          icon,
          color: isSelected && isEnabled
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (!state!.isUnselectable && isSelected) return;
    await state!.select(value, !isSelected);
    if (!state!.operationResult.isSuccess) _showOverlay(context);
  }

  void _showOverlay(BuildContext context) {
    state!.closeOverlay();
    state!.overlay = _buildOverlay(context);
    Overlay.of(context)!.insert(state!.overlay!);
  }

  OverlayEntry _buildOverlay(BuildContext context) {
    return createOverlayInTheMiddle(
      MessageOverlay(
        message: state!.operationResult.error!,
        style: state!.style.overlayStyle,
        closeIconSize: state!.style.closeIconSize,
        overlayController: state!.overlayController,
      ),
      context,
      state!.style.overlayStyle,
    );
  }
}
