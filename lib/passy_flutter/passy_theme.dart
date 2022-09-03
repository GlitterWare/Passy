import 'package:flutter/material.dart';

class PassyTheme {
  static const passyPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 8);
  static const appBarButtonSplashRadius = 28.0;
  static const appBarButtonPadding = EdgeInsets.all(16.0);

  static const ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );
  static const darkContentColor = Color.fromRGBO(38, 50, 56, 1);
  static const darkContentSecondaryColor = Color.fromRGBO(84, 110, 122, 1);
  static const lightContentColor = Color.fromRGBO(227, 242, 253, 1);
  static const lightContentSecondaryColor = Color.fromRGBO(144, 202, 249, 1);

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
      floatingLabelStyle: const TextStyle(color: lightContentSecondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(
          color: darkContentSecondaryColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: lightContentColor)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shadowColor:
            MaterialStateProperty.resolveWith((states) => Colors.transparent),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: lightContentColor,
      selectionColor: lightContentSecondaryColor,
      selectionHandleColor: lightContentColor,
    ),
  );

  static const ColorScheme datePickerColorScheme = ColorScheme.dark(
    primary: lightContentSecondaryColor,
    onPrimary: lightContentColor,
  );
}
