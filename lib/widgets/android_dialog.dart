// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';

class AndroidDialog extends StatelessWidget {
  const AndroidDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 350,
        height: 520,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(
                child: SvgPicture.asset(
              'assets/images/android_logo.svg',
              width: 64,
            )),
            const SizedBox(height: 24),
            const Text(
              'Passy for Android',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'FiraCode',
                color: PassyTheme.lightContentSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const PassyPadding(
              Text.rich(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'FiraCode',
                ),
                TextSpan(
                    text:
                        'Currently, Passy is only available on F-Droid.\n\nTo install and manage Passy using F-Droid, ',
                    children: [
                      TextSpan(
                        text: 'click the link button below',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      TextSpan(text: ' to visit the page and '),
                      TextSpan(
                        text: 'install the F-Droid store APK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      TextSpan(
                          text:
                              '.\n\nIf this is your first time installing APK files, you will need to '),
                      TextSpan(
                        text:
                            'grant your browser the permission to install apps from unknown sources',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ]),
              ),
            ),
            const SizedBox(height: 24),
            PassyPadding(ThreeWidgetButton(
              left: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: SvgPicture.asset(
                  'assets/images/fdroid.svg',
                  width: 24,
                ),
              ),
              center: const Text('F-Droid'),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => window.open(
                'https://f-droid.org/en/packages/com.glitterware.passy',
                'F-Droid',
              ),
            )),
            PassyPadding(ThreeWidgetButton(
              left: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: SvgPicture.asset(
                  'assets/images/play_store.svg',
                  width: 24,
                ),
              ),
              center: const Text('Play Store (Coming Soon)'),
              right: const Icon(Icons.arrow_forward_ios_rounded),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
