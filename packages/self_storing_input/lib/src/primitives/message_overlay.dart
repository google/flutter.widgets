// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:self_storing_input/self_storing_input.dart';

/// The panel that pops up to show a message.
class MessageOverlay extends StatelessWidget {
  final String message;
  final OverlayStyle style;
  final double? closeIconSize;
  final OverlayController? overlayController;

  const MessageOverlay(
      {required this.message,
      required this.style,
      this.closeIconSize,
      this.overlayController});

  @override
  Widget build(BuildContext context) {
    var iconSize =
        closeIconSize ?? (Theme.of(context).iconTheme.size ?? 24) / 2;
    return Column(children: [
      _buildButton(iconSize),
      _buildMessage(iconSize),
    ]);
  }

  Widget _buildButton(double iconSize) {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        height: iconSize,
        width: iconSize,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          icon: Icon(Icons.clear, size: iconSize),
          onPressed: overlayController!.close,
        ),
      ),
    );
  }

  Widget _buildMessage(double iconSize) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: style.height - iconSize - style.margin,
        child: SingleChildScrollView(
          child: Text(message),
        ),
      ),
    );
  }
}
