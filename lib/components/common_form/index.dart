import 'package:flutter/material.dart';

class CommonForm extends StatelessWidget {
  final Widget child;

  CommonForm({this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        child: Form(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
