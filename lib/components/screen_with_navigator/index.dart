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
            return new MaterialPageRoute(builder: (context) {
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

  ScreenWithNavigator({
    this.child,
    this.onGenerateRoute,
    this.onUnknownRoute,
  });

  @override
  ScreenWithNavigatorState createState() => new ScreenWithNavigatorState();
}
