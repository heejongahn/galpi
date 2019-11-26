import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:galpi/constants.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/components/screen_with_navigator/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/screens/book_list/index.dart';
import 'package:galpi/screens/review_list/index.dart';
import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/auth/email_login/index.dart';
import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/utils/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

final primaryColor = Color.fromRGBO(0xff, 0x74, 0x73, 1);

class WebviewArgument {
  final String title;
  final String link;

  WebviewArgument(this.title, this.link);
}

void main() => runApp(MaterialApp(
      home: MyApp(),
      theme: theme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  int _pageIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final homeItem = const BottomNavigationBarItem(
    icon: Icon(Icons.list),
    title: Text('피드'),
  );

  final myItem = const BottomNavigationBarItem(
      icon: Icon(Icons.person), title: Text('내 독후감'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    PackageInfo.fromPlatform().then((info) async {
      final prefs = await SharedPreferences.getInstance();
      final versionFromPrefs = prefs.getString(SHARED_PREFERENCE_VERSION_KEY);
      final lastVersion = versionFromPrefs != null ? versionFromPrefs : '1.0.0';

      if (lastVersion != info.version) {
        // TODO: 버전 업데이트 로직
      }
      prefs.setString(SHARED_PREFERENCE_VERSION_KEY, info.version);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loginIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: userRepository,
      child: Scaffold(
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

                        return Scaffold(
                          appBar: AppBar(title: Text(args.title)),
                          body: WebView(
                            initialUrl: args.link,
                            javascriptMode: JavascriptMode.unrestricted,
                          ),
                        );
                      }
                  }
                },
                // FIXME: 더 나은 방법을 찾아보자
                fullscreenDialog: settings.name.startsWith('/auth'),
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
      ),
    );
  }

  _loginIfAvailable() async {
    final link = (await FirebaseDynamicLinks.instance.getInitialLink()).link;
    final sharedPreference = await SharedPreferences.getInstance();

    final email = sharedPreference.getString(SHARED_PREFERENCE_LOGIN_EMAIL);

    if (email == null) {
      return;
    }

    try {
      final success = await userRepository.loginWithEmail(
        email: email,
        link: link.toString(),
      );

      if (success) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('${email}으로 로그인 되었습니다.'),
        ));
      }
    } catch (e) {
      print(e);
    }
  }
}
