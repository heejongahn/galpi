import 'package:flutter/material.dart';

class SafeAreaRoute extends MaterialPageRoute<dynamic> {
  SafeAreaRoute({Widget child, RouteSettings settings})
      : super(
          settings: settings,
          builder: (BuildContext context) {
            return SafeArea(child: child);
          },
        );
}
