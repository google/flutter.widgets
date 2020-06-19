import 'package:flutter/material.dart';

class TheProgressIndicator extends StatelessWidget {
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
