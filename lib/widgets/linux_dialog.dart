// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/screens/common.dart';

import 'common.dart';

class LinuxDialog extends StatelessWidget {
  const LinuxDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: SizedBox(
        width: 350,
        height: 750,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Center(
                child: SvgPicture.asset(
              'assets/images/linux.svg',
              width: 64,
            )),
            const SizedBox(height: 24),
            const Text(
              'Passy for Linux',
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
                        'Passy is available on many various Linux distribution stores.\n\nBefore checking out the links below, feel free to ',
                    children: [
                      TextSpan(
                        text:
                            'open your favorite software store and search for "Passy"',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      TextSpan(text: '.\nIt might already be there for you!'),
                    ]),
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/app_image_logo.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'AppImage',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://github.com/GlitterWare/Passy/releases/download/$releaseVersion$tagSuffix/Passy-$releaseVersion-x86-64.AppImage',
                    'AppImage',
                  ),
                )),
              ),
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/snap_store_icon.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'Snap Store',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://github.com/GlitterWare/Passy/blob/main/SNAP-STORE.md#snap-store-instructions',
                    'Snap Store',
                  ),
                )),
              ),
            ]),
            Row(children: [
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/flathub.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'Flathub',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://flathub.org/apps/io.github.glitterware.Passy',
                    'Flathub',
                  ),
                )),
              ),
              Expanded(
                child: PassyPadding(IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: dialogIconTopPadding),
                    child: SvgPicture.asset(
                      'assets/images/archlinux.svg',
                      width: dialogIconSize,
                    ),
                  ),
                  label: const Text(
                    'AUR',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://aur.archlinux.org/packages/passy',
                    'AUR',
                  ),
                )),
              ),
            ]),
            PassyPadding(IconedRectangleButton(
              icon: Padding(
                padding: const EdgeInsets.only(top: dialogIconTopPadding),
                child: SvgPicture.asset(
                  'assets/images/github_icon.svg',
                  width: dialogIconSize,
                ),
              ),
              label: const Text(
                'More',
                textAlign: TextAlign.center,
              ),
              onPressed: () => window.open(
                'https://github.com/GlitterWare/Passy/blob/main/DOWNLOADS.md#linux',
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
