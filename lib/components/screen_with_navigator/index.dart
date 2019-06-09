import 'package:flutter/material.dart';
import 'package:booklog/components/safe_area_route/index.dart';

class ScreenWithNavigatorState extends State<ScreenWithNavigator> {
  Widget child;

  ScreenWithNavigatorState({@required this.child}) {}

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return new SafeAreaRoute(settings: settings, child: child);
    });
  }
}

class ScreenWithNavigator extends StatefulWidget {
  final Widget child;

  ScreenWithNavigator({this.child}) {}

  @override
  ScreenWithNavigatorState createState() =>
      new ScreenWithNavigatorState(child: child);
}
