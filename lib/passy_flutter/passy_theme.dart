import 'package:flutter/material.dart';

class PassyTheme {
  static const passyPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 8);
  static const appBarButtonSplashRadius = 28.0;
  static const appBarButtonPadding = EdgeInsets.all(16.0);

  static final ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  );
  static final darkContentColor = Colors.blueGrey[900]!;
  static final darkContentSecondaryColor = Colors.blueGrey[600]!;
  static final lightContentColor = Colors.blue[50]!;
  static final lightContentSecondaryColor = Colors.blue[200]!;

  static final ThemeData theme = ThemeData(
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
      floatingLabelStyle: TextStyle(color: lightContentSecondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(
          color: darkContentSecondaryColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: lightContentColor)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shadowColor:
            MaterialStateProperty.resolveWith((states) => Colors.transparent),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightContentColor,
      selectionColor: lightContentSecondaryColor,
      selectionHandleColor: lightContentColor,
    ),
  );

  static final ThemeData datePickerTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: lightContentSecondaryColor,
      onPrimary: lightContentColor,
    ),
  );
}
