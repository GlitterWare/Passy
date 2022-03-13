import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture purpleLogo = SvgPicture.asset(
  'assets/images/logo.svg',
  color: Colors.purple,
);

final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(100),
);

final theme = ThemeData(
  primarySwatch: Colors.purple,
);
