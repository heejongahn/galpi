import 'package:flutter/material.dart';

final primaryColor = Colors.black;

final theme = ThemeData(
  fontFamily: 'SpoqaHan-Sans',
  accentColor: Colors.black87,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    elevation: 1,
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black, fontSize: 18),
    ),
  ),
  iconTheme: IconThemeData(color: primaryColor),
  textTheme: TextTheme(
    headline6: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  // buttonTheme:
  //     ButtonThemeData(colorScheme: ColorScheme.light(primary: primaryColor)),
);
