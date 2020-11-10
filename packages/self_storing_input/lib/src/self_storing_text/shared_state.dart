// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import '../primitives/overlay.dart';
import '../primitives/saver.dart';
import 'self_storing_text_style.dart';

/// State that needs to be shared between [OverlayBox] and its
/// parent.
class SharedState with ChangeNotifier {
  String? _storedValue;
  final OverlayController overlayController;
  final Saver saver;
  final Object itemKey;
  final SelfStoringTextStyle style;

  String? get storedValue => _storedValue;
  set storedValue(String? value) {
    if (value == _storedValue) return;
    _storedValue = value;
    notifyListeners();
  }

  SharedState({
    storedValue,
    required this.overlayController,
    required this.saver,
    required this.itemKey,
    required this.style,
  }) : _storedValue = storedValue;
}
