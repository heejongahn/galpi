import 'package:flutter/material.dart';

import 'package:booklog/screens/add_book/index.dart';
import 'package:booklog/screens/book_list/index.dart';
import 'package:booklog/screens/review_list/index.dart';

void main() => runApp(MaterialApp(home: MyApp()));

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

  final addItem = const BottomNavigationBarItem(
      icon: Icon(Icons.create), title: Text('새 리뷰'));

  final myItem = const BottomNavigationBarItem(
      icon: Icon(Icons.person), title: Text('MY'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
          index: _pageIndex, children: [Books(), AddBook(), Reviews()]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          homeItem,
          addItem,
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
