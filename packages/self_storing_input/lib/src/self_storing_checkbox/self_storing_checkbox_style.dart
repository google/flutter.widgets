// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import '../primitives/overlay.dart';

/// A style for [SelfStoringCheckbox].
class SelfStoringCheckboxStyle {
  /// Style of the error message box.
  final OverlayStyle overlayStyle;

  /// Size of the button that closes the error message box.
  final double closeIconSize;

  const SelfStoringCheckboxStyle(
      {this.closeIconSize = 18,
      this.overlayStyle = const OverlayStyle.forMessage()});
}
