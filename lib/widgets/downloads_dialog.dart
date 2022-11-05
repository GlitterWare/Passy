import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';

class DownloadsDialog extends StatelessWidget {
  const DownloadsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: SizedBox(
          width: 1200,
          height: 400,
          child: ListView(
            children: [
              PassyPadding(ThreeWidgetButton(
                left: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: SvgPicture.asset(
                      'assets/images/github_icon.svg',
                      width: 25,
                    )),
                center: const Text('GitHub'),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () => window.open(
                    'https://github.com/GlitterWare/Passy/releases/latest',
                    'Downloads'),
              )),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Flexible(
                      child: Text(
                        'Android',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Flexible(
                      child: Icon(Icons.android_rounded),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Flexible(
                    flex: 2,
                    child: PassyPadding(ThreeWidgetButton(
                      left: Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: SvgPicture.asset(
                            'assets/images/fdroid.svg',
                            width: 25,
                          )),
                      center: const Text('F-Droid'),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => window.open(
                          'https://f-droid.org/en/packages/com.glitterware.passy',
                          'F-Droid'),
                    )),
                  ),
                  const Spacer(),
                ],
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text(
                        'Windows',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Flexible(
                      child: SvgPicture.asset('assets/images/windows11.svg'),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Flexible(
                    flex: 2,
                    child: PassyPadding(ThreeWidgetButton(
                      left: Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: SvgPicture.asset(
                            'assets/images/github_icon.svg',
                            width: 25,
                          )),
                      center: const Text('GitHub'),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => window.open(
                          'https://github.com/GlitterWare/Passy/releases/latest',
                          'Downloads'),
                    )),
                  ),
                  const Spacer(),
                ],
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      flex: 12,
                      child: Text(
                        'Linux',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Flexible(
                      flex: 12,
                      child: SvgPicture.asset('assets/images/linux.svg'),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Flexible(
                      child: PassyPadding(ThreeWidgetButton(
                    left: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: SvgPicture.asset(
                          'assets/images/snap_store_icon.svg',
                          width: 25,
                        )),
                    center: const Text('Snap Store'),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () =>
                        window.open('https://snapcraft.io/passy', 'Snap Store'),
                  ))),
                  Flexible(
                      child: PassyPadding(ThreeWidgetButton(
                    left: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: SvgPicture.asset(
                          'assets/images/flathub.svg',
                          width: 25,
                        )),
                    center: const Text('Flathub'),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => window.open(
                        'https://flathub.org/apps/details/io.github.glitterware.Passy',
                        'Flathub'),
                  ))),
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  Flexible(
                    flex: 2,
                    child: PassyPadding(ThreeWidgetButton(
                      left: Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: SvgPicture.asset(
                            'assets/images/archlinux.svg',
                            width: 25,
                          )),
                      center: const Text('AUR'),
                      right: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () => window.open(
                          'https://aur.archlinux.org/packages/passy', 'AUR'),
                    )),
                  ),
                  const Spacer(),
                ],
              )
            ],
          ),
        ));
  }
}
