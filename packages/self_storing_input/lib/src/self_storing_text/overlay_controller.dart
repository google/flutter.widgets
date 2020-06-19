import 'package:flutter/material.dart';

/// A controller for overlay of a widget.
class OverlayController with ChangeNotifier {
  /// Closes overlay of the controlling widget. If there is no active overlay,
  /// nothing will happen.
  void close() {
    notifyListeners();
  }
}
