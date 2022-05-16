import 'package:flutter/material.dart';

const entryRecordPadding = EdgeInsets.symmetric(vertical: 10, horizontal: 10);

final theme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.purple[900]!,
    onPrimary: Colors.blue[50]!,
    secondary: Colors.purple[700]!,
    onSecondary: Colors.blue[50]!,
    onSurface: Colors.blue[50]!,
  ),
  scaffoldBackgroundColor: Colors.blueGrey[900],
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shadowColor:
          MaterialStateProperty.resolveWith((states) => Colors.transparent),
    ),
  ),
);
