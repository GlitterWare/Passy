import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../passy_flutter/passy_flutter.dart';

const String logoSvg = 'assets/images/logo.svg';
const String logoCircleSvg = 'assets/images/logo_circle.svg';

SvgPicture logoCircle50White = SvgPicture.asset(
  logoCircleSvg,
  colorFilter:
      const ColorFilter.mode(PassyTheme.lightContentColor, BlendMode.srcIn),
  width: 50,
);

SvgPicture logo60Purple = SvgPicture.asset(
  logoSvg,
  colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
  width: 60,
);
