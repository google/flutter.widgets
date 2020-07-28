// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import '../primitives/operation_result.dart';
import '../primitives/overlay.dart';
import '../primitives/saver.dart';
import 'self_storing_checkbox_style.dart';

/// State that needs to be shared between main widget and children.
class SharedState with ChangeNotifier {
  final Saver saver;
  final Object itemKey;
  final OverlayController overlayController;
  final SelfStoringCheckboxStyle style;
  final bool tristate;

  bool storedValue;
  OperationResult operationResult = OperationResult.success();

  bool _isSaving = false;
  bool get isSaving => _isSaving;
  set isSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  SharedState({
    this.saver,
    this.itemKey,
    this.overlayController,
    this.style,
    this.tristate,
    this.storedValue,
  });
}
