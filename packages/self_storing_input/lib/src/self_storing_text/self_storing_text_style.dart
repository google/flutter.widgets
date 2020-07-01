import 'package:flutter/material.dart';
import 'package:self_storing_input/self_storing_input.dart';

/// A style for [SelfStoringText].
class SelfStoringTextStyle {
  final OverlayStyle overlayStyle;
  final TextInputType keyboardType;

  /// Maximum number of lines. Infinite if null.
  ///
  /// Behaves the same way as [Text.maxLines].
  final int maxLines;

  const SelfStoringTextStyle(
      {this.overlayStyle = const OverlayStyle(),
      this.keyboardType,
      this.maxLines = 1});
}
