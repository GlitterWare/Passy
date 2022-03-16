import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture purpleLogo = SvgPicture.asset(
  'assets/images/logo.svg',
  color: Colors.purple,
  width: 60,
);

final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(100),
);

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
);
