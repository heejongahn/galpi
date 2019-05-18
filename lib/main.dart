import 'package:flutter/material.dart';
import 'screens/book_list/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: Books(),
    );
  }
}
