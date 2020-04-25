import 'package:flutter/material.dart';

class ScreenWithNavigatorState extends State<ScreenWithNavigator> {
  ScreenWithNavigatorState();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: widget.onGenerateRoute != null ? '/' : null,
      onUnknownRoute: widget.onUnknownRoute,
      onGenerateRoute: widget.onGenerateRoute ??
          (RouteSettings settings) {
            return MaterialPageRoute<dynamic>(builder: (context) {
              return widget.child;
            });
          },
    );
  }
}

class ScreenWithNavigator extends StatefulWidget {
  final Widget child;
  final RouteFactory onGenerateRoute;
  final RouteFactory onUnknownRoute;

  const ScreenWithNavigator({
    this.child,
    this.onGenerateRoute,
    this.onUnknownRoute,
  });

  @override
  ScreenWithNavigatorState createState() => ScreenWithNavigatorState();
}
