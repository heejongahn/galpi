import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galpi/logged_in_app.dart';
import 'package:provider/provider.dart';

import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/screens/auth/email_login/index.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        if (userRepository.user == null) {
          return Scaffold(
            body: EmailLogin(),
          );
        }

        return LoggedInApp();
      },
    );
  }
}
