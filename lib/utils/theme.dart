import 'package:flutter/material.dart';

final primaryColor = Colors.black;

final theme = ThemeData(
  fontFamily: 'SpoqaHan-Sans',
  accentColor: Colors.black87,
  primaryColor: primaryColor,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    elevation: 1,
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      title: TextStyle(color: Colors.black, fontSize: 18),
    ),
  ),
  iconTheme: IconThemeData(color: primaryColor),
  textTheme: TextTheme(
    title: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
  // buttonTheme:
  //     ButtonThemeData(colorScheme: ColorScheme.light(primary: primaryColor)),
);
