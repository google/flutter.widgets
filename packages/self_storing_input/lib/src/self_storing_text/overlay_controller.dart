import 'package:flutter/material.dart';

/// A controller for the overlay of a widget,
/// a floating dialog box used to
/// edit the text and to commit or cancel changes.
class OverlayController with ChangeNotifier {
  /// Closes overlay of the controlling widget. If there is no active overlay,
  /// nothing will happen.
  void close() {
    notifyListeners();
  }
}
