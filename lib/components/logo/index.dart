import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double fontSize;

  const Logo({Key key, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'galpi',
      style: TextStyle(
        fontFamily: 'Abril-Fatface',
        fontSize: fontSize,
      ),
    );
  }
}
