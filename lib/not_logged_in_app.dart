import 'package:flutter/material.dart';

import 'package:galpi/components/screen_with_navigator/index.dart';
import 'package:galpi/screens/auth/email_login/index.dart';
import 'package:galpi/screens/auth/email_password/login.dart';
import 'package:galpi/screens/auth/email_password/register.dart';
import 'package:galpi/screens/auth/index.dart';

class NotLoggedInApp extends StatefulWidget {
  @override
  _NotLoggedInAppState createState() => _NotLoggedInAppState();
}

class _NotLoggedInAppState extends State<NotLoggedInApp>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ScreenWithNavigator(
        child: Auth(),
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<dynamic>(
            builder: (_) {
              switch (settings.name) {
                case '/':
                  {
                    return Auth();
                  }
                case '/auth/email':
                  {
                    return EmailLogin();
                  }
                case '/auth/email-password/login':
                  {
                    return EmailPasswordLogin();
                  }
                case '/auth/email-password/register':
                  {
                    return EmailPasswordRegister();
                  }
              }

              // FIXME: Not Found Page?
              return Container();
            },
          );
        },
        onUnknownRoute: (_) {
          return MaterialPageRoute<dynamic>(
            builder: (context) {
              return Auth();
            },
          );
        },
      ),
    );
  }
}
