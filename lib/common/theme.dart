import 'package:flutter/material.dart';

final theme = ThemeData(
  primarySwatch: Colors.purple,
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
