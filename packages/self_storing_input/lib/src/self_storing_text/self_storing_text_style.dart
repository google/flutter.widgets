// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/self_storing_input.dart';

/// A style for [SelfStoringText].
class SelfStoringTextStyle {
  final OverlayStyle overlayStyle;
  final TextInputType? keyboardType;

  /// Maximum number of lines. Infinite if null.
  ///
  /// Behaves the same way as [Text.maxLines].
  final int maxLines;

  const SelfStoringTextStyle(
      {this.overlayStyle = const OverlayStyle.forTextEditor(),
      this.keyboardType,
      this.maxLines = 1});
}
