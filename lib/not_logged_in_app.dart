import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/screen_with_navigator/index.dart';
import 'package:galpi/constants.dart';
import 'package:galpi/screens/auth/email_login/index.dart';
import 'package:galpi/screens/auth/email_password/login.dart';
import 'package:galpi/screens/auth/email_password/register.dart';
import 'package:galpi/screens/auth/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initializeFirebaseDynamicLinks();
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

  Future<void> _initializeFirebaseDynamicLinks() async {
    final firebaseDLInstance = FirebaseDynamicLinks.instance;

    final initialLink = await firebaseDLInstance.getInitialLink();

    if (initialLink != null) {
      await _loginIfAvailable(initialLink.link);
    }

    firebaseDLInstance.onLink(
      onSuccess: (data) async {
        _loginIfAvailable(data.link);
      },
      onError: (error) async {
        print(error);
      },
    );
  }

  Future<void> _loginIfAvailable(Uri link) async {
    final userRepository = Provider.of<UserRepository>(context);

    if (userRepository.user != null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final email = sharedPreference.getString(SHARED_PREFERENCE_LOGIN_EMAIL);

    if (email == null) {
      return;
    }

    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
          content: Text(
        '${email}으로 로그인 중',
      )),
    );

    try {
      final authResult = await userRepository.loginWithEmail(
        email: email,
        link: link.toString(),
      );

      Scaffold.of(context).removeCurrentSnackBar();
      if (!authResult.item1) {
        throw Error();
      } else {}
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        const SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
        ),
      );
      rethrow;
    }
  }
}
