// Copyright 2020 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';

Widget get theProgressIndicator => const _ProgressIndicator();

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: EdgeInsets.all(8),
      child: Align(child: CircularProgressIndicator()),
    );
  }
}
