import 'package:flutter/material.dart';

import 'package:booklog/components/screen_with_navigator/index.dart';
import 'package:booklog/screens/book_list/index.dart';
import 'package:booklog/screens/review_list/index.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      theme: ThemeData(fontFamily: 'Spoqa-Han-Sans'),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _pageIndex = 0;

  final homeItem = const BottomNavigationBarItem(
    icon: Icon(Icons.list),
    title: Text('피드'),
  );

  final myItem = const BottomNavigationBarItem(
      icon: Icon(Icons.person), title: Text('내 리뷰'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: [
        ScreenWithNavigator(child: Books()),
        ScreenWithNavigator(child: Reviews())
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          homeItem,
          myItem,
        ],
        currentIndex: _pageIndex,
        onTap: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
