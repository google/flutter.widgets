import 'package:flutter/material.dart';

/// A style for [SelfStoringText].
class SelfStoringTextStyle {
  final double offsetLeft;
  final double offsetTop;
  final double overlayElevation;
  final double overlayWidth;
  final double overlayHeight;
  final double overlayMargin;
  final TextInputType keyboardType;

  /// Maximum number of lines. Infinite, if null.
  ///
  /// Behaves the same way as [Text.maxLines].
  /// https://api.flutter.dev/flutter/widgets/Text/maxLines.html
  final int maxLines;

  const SelfStoringTextStyle(
      {this.offsetLeft = 24,
      this.offsetTop = 24,
      this.overlayElevation = 4.0,
      this.overlayWidth = 500,
      this.overlayHeight = 100,
      this.overlayMargin = 8,
      this.keyboardType,
      this.maxLines = 1});
}
