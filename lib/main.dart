import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galpi/app.dart';
import 'package:galpi/utils/env.dart';
import 'package:provider/provider.dart';

import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/utils/theme.dart';

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

    setState(() {
      isInitialized = true;
    });
  }
}
