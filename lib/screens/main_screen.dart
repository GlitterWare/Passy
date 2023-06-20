// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/widgets/about_passy_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  void _generatePassword() {
    showDialog(context: context, builder: (_) => const StringGeneratorDialog())
        .then((value) {
      if (value == null) return;
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: const [
        Icon(
          Icons.password,
          color: PassyTheme.darkContentColor,
        ),
        SizedBox(width: 20),
        Expanded(child: Text('Password copied!')),
      ])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
              'Passy - Offline password manager with cross-platform synchronization'),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(children: [
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
                      'https://github.com/GlitterWare/Passy', 'GitHub'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.extension_rounded),
                  ),
                  center: const Text('Browser Extension'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => window.open(
                      'https://github.com/GlitterWare/Passy-Browser-Extension/blob/main/DOWNLOADS.md',
                      'Browser Extension'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.download_rounded),
                  ),
                  center: const Text('Downloads'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => window.open(
                      'https://github.com/GlitterWare/Passy/blob/dev/DOWNLOADS.md',
                      'Downloads'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.password)),
                  center: const Text('Password generator'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: _generatePassword,
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.money_rounded),
                  ),
                  center: const Text('Donate'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => window.open(
                      'https://github.com/sponsors/GlitterWare', 'Donate'),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.shield_moon_outlined),
                  ),
                  center: const Text('Privacy policy'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => window.open(
                    'https://github.com/GlitterWare/Passy/blob/main/PRIVACY-POLICY.md',
                    'Privacy policy',
                  ),
                )),
                PassyPadding(ThreeWidgetButton(
                  left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.info_outline_rounded)),
                  center: const Text('About'),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const AboutPassyDialog()),
                )),
              ]),
            )
          ],
        ));
  }
}
