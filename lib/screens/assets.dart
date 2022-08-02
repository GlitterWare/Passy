import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const String logoSvg = 'assets/images/logo.svg';
const String logoCircleSvg = 'assets/images/logo_circle.svg';

SvgPicture logoCircle50White = SvgPicture.asset(
  logoCircleSvg,
  color: Colors.white,
  width: 50,
  fit: BoxFit.fill,
);

SvgPicture logo60Purple = SvgPicture.asset(
  logoSvg,
  color: Colors.purple,
  width: 60,
);
