import 'package:flutter/material.dart';

class SafeAreaRoute extends MaterialPageRoute {
  SafeAreaRoute({child, settings})
      : super(
            settings: settings,
            builder: (BuildContext context) {
              return SafeArea(child: child);
            });
}
