import 'package:flutter/material.dart';

final primaryColor = Colors.black;

final theme = ThemeData(
  fontFamily: 'SpoqaHan-Sans',
  accentColor: Colors.black87,
  primaryColor: primaryColor,
  appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      textTheme:
          TextTheme(title: TextStyle(color: Colors.white, fontSize: 18))),
  iconTheme: IconThemeData(color: primaryColor),
  // buttonTheme:
  //     ButtonThemeData(colorScheme: ColorScheme.light(primary: primaryColor)),
);
