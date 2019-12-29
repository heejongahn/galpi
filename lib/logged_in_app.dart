import 'package:flutter/material.dart';

import 'package:galpi/components/screen_with_navigator/index.dart';

import 'package:galpi/migrations/index.dart';

import 'package:galpi/screens/webview/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/screens/book_list/index.dart';
import 'package:galpi/screens/review_list/index.dart';
import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/auth/email_login/index.dart';
import 'package:galpi/screens/review_detail/index.dart';

class LoggedInApp extends StatefulWidget {
  @override
  _LoggedInAppState createState() => _LoggedInAppState();
}

class _LoggedInAppState extends State<LoggedInApp> with WidgetsBindingObserver {
  int _pageIndex = 1;
  bool isMigrationFinished = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    runAllNeededMigrations().then((_) {
      setState(() {
        isMigrationFinished = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isMigrationFinished) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(index: _pageIndex, children: [
        ScreenWithNavigator(
          child: Books(),
        ),
        ScreenWithNavigator(
          child: Reviews(),
          onGenerateRoute: (RouteSettings settings) {
            return new MaterialPageRoute(
              builder: (_) {
                switch (settings.name) {
                  case '/':
                    {
                      return Reviews();
                    }
                  case '/review/add':
                    {
                      return AddReview();
                    }
                  case '/review/write':
                    {
                      final WriteReviewArgument args = settings.arguments;
                      return WriteReview(arguments: args);
                    }
                  case '/review/detail':
                    {
                      final ReviewDetailArguments args = settings.arguments;
                      return ReviewDetail(arguments: args);
                    }
                  case '/auth/email-login':
                    {
                      return EmailLogin();
                    }
                  case '/webview':
                    {
                      final WebviewArgument args = settings.arguments;

                      return Webview(
                        args: args,
                      );
                    }
                }
              },
              // FIXME: 더 나은 방법을 찾아보자
              // fullscreenDialog: settings.name.startsWith('/auth'),
            );
          },
          onUnknownRoute: (_) {
            return MaterialPageRoute(
              builder: (context) {
                return Reviews();
              },
            );
          },
        )
      ]),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [
      //     homeItem,
      //     myItem,
      //   ],
      //   currentIndex: _pageIndex,
      //   onTap: (int index) {
      //     setState(() {
      //       _pageIndex = index;
      //     });
      //   },
      // ),
    );
  }
}
