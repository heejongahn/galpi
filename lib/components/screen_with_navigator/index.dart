import 'package:flutter/material.dart';

class ScreenWithNavigatorState extends State<ScreenWithNavigator> {
  Widget child;

  ScreenWithNavigatorState({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return new MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return child;
          });
    });
  }
}

class ScreenWithNavigator extends StatefulWidget {
  final Widget child;

  ScreenWithNavigator({this.child});

  @override
  ScreenWithNavigatorState createState() =>
      new ScreenWithNavigatorState(child: child);
}
