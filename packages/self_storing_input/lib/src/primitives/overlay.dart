import 'package:flutter/material.dart';

/// A controller for the overlay of a widget,
/// a floating dialog box used to
/// edit/save the value and/or notify about errors.
class OverlayController with ChangeNotifier {
  /// Closes the overlay of the controlling widget. If there is no active overlay,
  /// nothing will happen.
  void close() {
    notifyListeners();
  }
}

class OverlayStyle {
  final double elevation;
  final double width;
  final double height;
  final double margin;

  const OverlayStyle({
    this.elevation = 4.0,
    this.width = 500,
    this.height = 100,
    this.margin = 8,
  });
}
