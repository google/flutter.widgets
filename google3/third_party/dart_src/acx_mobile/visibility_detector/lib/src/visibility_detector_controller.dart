// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'visibility_detector_layer.dart';

/// A [VisibilityDetectorController] is a singleton object that can perform
/// actions and change configuration for all [VisibilityDetector] widgets.
class VisibilityDetectorController {
  static final _instance = VisibilityDetectorController();
  static VisibilityDetectorController get instance => _instance;

  /// The minimum amount of time to wait between firing batches of visibility
  /// callbacks.
  ///
  /// If set to [Duration.zero], callbacks instead will fire at the end of every
  /// frame.  This is useful for automated tests.
  ///
  /// Changing [updateInterval] will not affect any pending callbacks.  Clients
  /// should call [notifyNow] explicitly to flush them if desired.
  Duration updateInterval = Duration(milliseconds: 500);

  /// Forces firing all pending visibility callbacks immmediately.
  ///
  /// This might be desirable just prior to tearing down the widget tree (such
  /// as when switching views or when exiting the application).
  void notifyNow() {
    VisibilityDetectorLayer.notifyNow();
  }
}
