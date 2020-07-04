import 'package:flutter/material.dart';

import 'package:galpi/components/screen_with_navigator/index.dart';

import 'package:galpi/migrations/index.dart';

import 'package:galpi/screens/edit_profile/index.dart';
import 'package:galpi/screens/review_preview/index.dart';
import 'package:galpi/screens/webview/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/screens/review_list/index.dart';
import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/review_detail/index.dart';

class LoggedInApp extends StatefulWidget {
  @override
  _LoggedInAppState createState() => _LoggedInAppState();
}

class _LoggedInAppState extends State<LoggedInApp> with WidgetsBindingObserver {
  final int _pageIndex = 0;
  bool isMigrationFinished = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(index: _pageIndex, children: [
        // ScreenWithNavigator(
        //   child: Books(),
        // ),
        ScreenWithNavigator(
          child: Reviews(),
          onGenerateRoute: (RouteSettings settings) {
            final fullscreenPrefixes = ['/profile', '/review/preview'];

            return MaterialPageRoute<dynamic>(
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
                      final args = settings.arguments as WriteReviewArgument;
                      return WriteReview(arguments: args);
                    }
                  case '/review/detail':
                    {
                      final args = settings.arguments as ReviewDetailArguments;
                      return ReviewDetail(arguments: args);
                    }
                  case '/review/preview':
                    {
                      final args = settings.arguments as ReviewPreviewArguments;
                      return ReviewPreview(arguments: args);
                    }
                  case '/profile/edit':
                    {
                      return EditProfile();
                    }
                  case '/webview':
                    {
                      final args = settings.arguments as WebviewArgument;

                      return Webview(
                        args: args,
                      );
                    }
                }

                // FIXME: Not Found Page?
                return Container();
              },
              // FIXME: 더 나은 방법을 찾아보자
              fullscreenDialog: fullscreenPrefixes.indexWhere((prefix) {
                    return settings.name.startsWith(prefix);
                  }) !=
                  -1,
            );
          },
          onUnknownRoute: (_) {
            return MaterialPageRoute<dynamic>(
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
