import 'package:flutter/material.dart';

final primaryColor = Color.fromRGBO(0xc6, 0x51, 0x46, 1);

final theme = ThemeData(
    fontFamily: 'Spoqa-Han-Sans',
    accentColor: primaryColor,
    primaryColor: primaryColor,
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        textTheme:
            TextTheme(title: TextStyle(color: Colors.white, fontSize: 18))),
    iconTheme: IconThemeData(color: primaryColor),
    buttonTheme:
        ButtonThemeData(colorScheme: ColorScheme.dark(primary: primaryColor)),
    buttonColor: primaryColor);
