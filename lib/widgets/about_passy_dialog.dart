// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';

class AboutPassyDialog extends StatelessWidget {
  const AboutPassyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 350,
        height: 510,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(
                child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 128,
            )),
            const SizedBox(height: 24),
            const Text(
              'Passy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'FiraCode',
                color: PassyTheme.lightContentSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const PassyPadding(
              Text(
                'Store passwords, payment cards, notes, ID cards and identities offline and safe, synchronized between all of your devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'FiraCode',
                ),
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
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.shield_moon_outlined),
              ),
              center: const Text('Privacy policy'),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => window.open(
                'https://github.com/GlitterWare/Passy/blob/main/PRIVACY-POLICY.md#privacy-policy',
                'Privacy policy',
              ),
            )),
            PassyPadding(ThreeWidgetButton(
              left: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: SvgPicture.asset(
                  'assets/images/github_icon.svg',
                  width: 24,
                ),
              ),
              center: const Text('GitHub'),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  window.open('https://github.com/GlitterWare/Passy', 'GitHub'),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
