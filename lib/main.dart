import 'dart:async';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galpi/app.dart';
import 'package:galpi/utils/env.dart';
import 'package:galpi/utils/is_debug_mode.dart';
import 'package:provider/provider.dart';

import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/utils/theme.dart';
import 'package:sentry/sentry.dart' show SentryClient;

final SentryClient sentry = SentryClient(dsn: env.sentryDSN);

void main() {
  FlutterError.onError = (details, {bool forceReport = false}) {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned(
    () => runApp(
      MaterialApp(
        home: MyApp(),
        theme: theme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
      ),
    ),
    onError: (Object error, StackTrace stackTrace) {
      try {
        if (isInDebugMode) {
          print(stackTrace);
        }

        sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
        print('Error sent to sentry.io: $error');
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
        print('Original error: $error');
      }
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isInitialized = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: const CircularProgressIndicator(),
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

  Future<void> _initialize() async {
    WidgetsBinding.instance.addObserver(this);

    await loadEnvForCurrentFlavor();
    await userRepository.initialize();

    setState(() {
      isInitialized = true;
    });
  }
}
