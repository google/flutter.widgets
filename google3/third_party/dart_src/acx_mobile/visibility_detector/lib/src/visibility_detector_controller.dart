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
  Duration updateInterval = Duration(milliseconds: 500);

  /// Forces firing all pending visibility callbacks immmediately.
  void notifyNow() {
    VisibilityDetectorLayer.notifyNow();
  }
}
