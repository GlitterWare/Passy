import 'package:flutter/material.dart';

const entryPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 8);

final darkContentColor = Colors.blueGrey[900]!;
final lightContentColor = Colors.blue[50]!;
final lightContentSecondaryColor = Colors.blue[200]!;

final theme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.purple[900]!,
    onPrimary: lightContentColor,
    secondary: Colors.purple[700]!,
    onSecondary: lightContentColor,
    onSurface: lightContentColor,
  ),
  snackBarTheme: SnackBarThemeData(actionTextColor: Colors.blueGrey[900]),
  scaffoldBackgroundColor: darkContentColor,
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
