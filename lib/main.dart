import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galpi/app.dart';
import 'package:galpi/constants.dart';
import 'package:galpi/utils/env.dart';
import 'package:provider/provider.dart';

import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final primaryColor = Color.fromRGBO(0xff, 0x74, 0x73, 1);

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
  bool isInitialized = false;
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
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }

    return ChangeNotifierProvider.value(
      value: userRepository,
      child: Scaffold(
        key: _scaffoldKey,
        body: App(),
      ),
    );
  }

  _initialize() async {
    WidgetsBinding.instance.addObserver(this);

    await loadEnvForCurrentFlavor();
    await userRepository.initialize();
    await _initializeFirebaseDynamicLinks();

    setState(() {
      isInitialized = true;
    });
  }

  _initializeFirebaseDynamicLinks() async {
    final firebaseDLInstance = FirebaseDynamicLinks.instance;

    await firebaseDLInstance.getInitialLink().then((data) {
      if (data != null) {
        _loginIfAvailable(data.link);
      }
    });

    firebaseDLInstance.onLink(
      onSuccess: (data) async {
        _loginIfAvailable(data.link);
      },
      onError: (error) async {
        print(error);
      },
    );
  }

  _loginIfAvailable(Uri link) async {
    if (userRepository.user != null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final email = sharedPreference.getString(SHARED_PREFERENCE_LOGIN_EMAIL);

    if (email == null) {
      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('${email}으로 로그인 중'),
    ));

    try {
      final success = await userRepository.loginWithEmail(
        email: email,
        link: link.toString(),
      );

      if (success) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('${email}으로 로그인 되었습니다.'),
        ));
      } else {
        throw new Error();
      }
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('로그인 실패'),
      ));
    }
  }
}
