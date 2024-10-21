import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/screens/common.dart';

import '../passy_theme.dart';
import 'passy_padding.dart';
import 'three_widget_button.dart';

class PassyAboutDialog extends StatelessWidget {
  const PassyAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: PassyTheme.dialogShape,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Center(
              child: SvgPicture.asset(
            logoSvg,
            colorFilter: const ColorFilter.mode(Colors.purple, BlendMode.srcIn),
            width: 128,
          )),
          const SizedBox(height: 32),
          Text.rich(
            TextSpan(
              text: 'Passy ',
              style: const TextStyle(fontFamily: 'FiraCode'),
              children: [
                TextSpan(
                  text: 'v$passyVersion',
                  style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor,
                  ),
                )
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Account version: $accountVersion\nSync version: $syncVersion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'FiraCode',
              color: PassyTheme.of(context).highlightContentSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Made with 💜 by Gleammer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'FiraCode',
            ),
          ),
          const SizedBox(height: 24),
          PassyPadding(ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SvgPicture.asset(
                'assets/images/github_icon.svg',
                width: 26,
                colorFilter: ColorFilter.mode(
                    PassyTheme.of(context).highlightContentColor,
                    BlendMode.srcIn),
              ),
            ),
            center: const Text('GitHub'),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => openUrl(
              'https://github.com/GlitterWare/Passy',
            ),
          )),
          PassyPadding(ThreeWidgetButton(
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.notes),
            ),
            center: const Text('Licenses'),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => showLicensePage(context: context),
          )),
        ],
      ),
    );
  }
}
