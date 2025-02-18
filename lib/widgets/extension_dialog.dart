// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/screens/common.dart';

class ExtensionDialog extends StatelessWidget {
  const ExtensionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 350,
        height: 630,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const Center(child: Icon(Icons.extension, size: 64)),
            const SizedBox(height: 24),
            const Text(
              'Passy Browser Extension',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'FiraCode',
                color: PassyTheme.lightContentSecondaryColor,
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
            Row(children: [
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/google_chrome.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'Google Chrome',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://chrome.google.com/webstore/detail/passy-password-manager-br/lndgiajgfcgocmgdiamhffipffjnpigl',
                    'Google Chrome',
                  ),
                )),
              ),
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/microsoft_edge.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'Microsoft Edge',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://microsoftedge.microsoft.com/addons/detail/passy-password-manager-/khcfpejnhlonmipnjmlebjncibplamff',
                    'Microsoft Edge',
                  ),
                )),
              ),
            ]),
            PassyPadding(IconedRectangleButton(
              icon: Padding(
                padding: const EdgeInsets.only(top: dialogIconTopPadding),
                child: SvgPicture.asset(
                  'assets/images/firefox_focus.svg',
                  width: dialogIconSize,
                ),
              ),
              label: const Text(
                'Mozilla Firefox',
                textAlign: TextAlign.center,
              ),
              onPressed: () => window.open(
                'https://addons.mozilla.org/en-US/firefox/addon/passy/',
                'Mozilla Firefox',
              ),
            )),
            PassyPadding(IconedRectangleButton(
              icon: Padding(
                padding: const EdgeInsets.only(top: dialogIconTopPadding),
                child: SvgPicture.asset(
                  'assets/images/github_icon.svg',
                  width: dialogIconSize,
                ),
              ),
              label: const Text(
                'Source',
                textAlign: TextAlign.center,
              ),
              onPressed: () => window.open(
                'https://github.com/GlitterWare/Passy-Browser-Extension',
                'GitHub',
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
