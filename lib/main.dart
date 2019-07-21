import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:galpi/components/screen_with_navigator/index.dart';
import 'package:galpi/screens/book_list/index.dart';
import 'package:galpi/screens/review_list/index.dart';
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

class _MyAppState extends State<MyApp> {
  int _pageIndex = 1;

  final homeItem = const BottomNavigationBarItem(
    icon: Icon(Icons.list),
    title: Text('피드'),
  );

  final myItem = const BottomNavigationBarItem(
      icon: Icon(Icons.person), title: Text('내 독후감'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: [
        ScreenWithNavigator(child: Books()),
        ScreenWithNavigator(child: Reviews())
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
