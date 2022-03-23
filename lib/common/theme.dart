import 'package:flutter/material.dart';

final theme = ThemeData(
  primarySwatch: Colors.purple,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black),
    toolbarTextStyle: TextStyle(color: Colors.black),
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
    ),
  ),
);
