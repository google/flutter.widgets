// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

import 'shared_state.dart';

/// The panel that pops up to show error message.
class OverlayBox extends StatelessWidget {
  final SharedState sharedState;

  const OverlayBox(this.sharedState);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildButton(),
      _buildMessage(),
    ]);
  }

  Widget _buildButton() {
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        height: sharedState.style.closeIconSize,
        width: sharedState.style.closeIconSize,
        child: IconButton(
          padding: EdgeInsets.all(0.0),
          icon: Icon(Icons.clear, size: sharedState.style.closeIconSize),
          onPressed: () => sharedState.overlayController.close(),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: sharedState.style.overlayStyle.height -
            sharedState.style.closeIconSize -
            sharedState.style.overlayStyle.margin,
        child: SingleChildScrollView(
          child: Text(sharedState.operationResult.error ?? ''),
        ),
      ),
    );
  }
}
