import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galpi/logged_in_app.dart';
import 'package:galpi/not_logged_in_app.dart';
import 'package:galpi/screens/auth/email_verification_needed/index.dart';
import 'package:provider/provider.dart';

import 'package:galpi/stores/user_repository.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  bool isInitialized = false;

  @override
  void initState() {
    final userRepository = Provider.of<UserRepository>(context, listen: false);

    super.initState();
    userRepository.initialize().then<void>(
      (_) {
        setState(() {
          isInitialized = true;
        });
      },
    ).catchError((Object _) {
      setState(() {
        isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        if (!isInitialized) {
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }

        switch (userRepository.authStatus) {
          case AuthStatus.Authenticated:
            {
              return LoggedInApp();
            }
          case AuthStatus.NeedsEmailVerification:
            {
              return EmailVerificationNeeded();
            }
          case AuthStatus.Unauthenticated:
            {
              return NotLoggedInApp();
            }
        }

        return NotLoggedInApp();
      },
    );
  }
}
