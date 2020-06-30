import 'package:flutter/material.dart';

Widget get theProgressIndicator => const _ProgressIndicator();

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: EdgeInsets.all(8),
      child: Align(child: CircularProgressIndicator()),
    );
  }
}
