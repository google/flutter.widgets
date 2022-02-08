// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/self_storing_input.dart';

/// State that needs to be shared between main widget and children.
class SharedState with ChangeNotifier {
  final Saver saver;
  final Object itemKey;
  final SelfStoringRadioGroupStyle style;
  final OverlayController overlayController;
  final Object? defaultValue;

  /// If true, the radio buttons in the group can be unselected,
  /// returning to the state when user did not enter value yet.
  final bool isUnselectable;

  OverlayEntry? overlay;
  OperationResult operationResult = OperationResult.success();
  Object? storedValue;

  Object? get selectedValue => _selectedValue;
  Object? _selectedValue;

  /// Value of the radio button, that caused the change of the value and
  /// triggered the saving operation.
  /// We need it to show the spinning wheel.
  Object? get pendingValue => _pendingValue;
  Object? _pendingValue;

  Object get isSaving => _isSaving;
  Object _isSaving = false;

  SharedState(
    this.defaultValue,
    this.overlayController,
    this.saver,
    this.itemKey,
    this.style,
    this.storedValue,
    this.isUnselectable,
  ) : _selectedValue = storedValue;

  /// Tries to save the [value], showing spinning wheal near [newPendingValue]
  /// while saving.
  Future<void> select(Object value, bool selected) async {
    _selectedValue = selected ? value : defaultValue;
    _pendingValue = value;
    _isSaving = true;
    notifyListeners();
    operationResult = await saver.save(itemKey, _selectedValue);
    if (operationResult.isSuccess) {
      storedValue = _selectedValue;
    } else {
      _selectedValue = storedValue;
    }
    _isSaving = false;
    notifyListeners();
  }

  void closeOverlay() {
    overlay?.remove();
    overlay = null;
    notifyListeners();
  }
}
