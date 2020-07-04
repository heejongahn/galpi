import 'package:flutter/material.dart';

final primaryColor = Colors.black;

final theme = ThemeData(
  fontFamily: 'SpoqaHan-Sans',
  accentColor: Colors.black87,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    brightness: Brightness.light,
    elevation: 1,
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black, fontSize: 18),
    ),
  ),
  iconTheme: IconThemeData(color: primaryColor),
  textTheme: const TextTheme(
    bodyText2: TextStyle(
      fontSize: 16,
      height: 1.6,
    ),
    headline6: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  // buttonTheme:
  //     ButtonThemeData(colorScheme: ColorScheme.light(primary: primaryColor)),
);
