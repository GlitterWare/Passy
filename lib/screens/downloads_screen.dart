// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/widgets/android_dialog.dart';
import 'package:passy_website/widgets/extension_dialog.dart';
import 'package:passy_website/widgets/linux_dialog.dart';

import 'common.dart';

class DownloadsScreen extends StatefulWidget {
  static const String routeName = '/downloads';

  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreen();
}

class _DownloadsScreen extends State<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passy - Downloads'),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: PassyPadding(SizedBox(
                      height: 200,
                      child: IconedRectangleButton(
                        icon: const Padding(
                          padding: EdgeInsets.only(top: 35),
                          child: Icon(
                            Icons.window,
                            size: iconSize,
                          ),
                        ),
                        label: const Text(
                          'Windows Installer',
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => window.open(
                            'https://github.com/GlitterWare/Passy/releases/download/v1.8.0/Passy-v1.8.0-Windows-Installer.exe',
                            'Windows'),
                      ))),
                ),
                Expanded(
                  child: PassyPadding(SizedBox(
                      height: 200,
                      child: IconedRectangleButton(
                        icon: const Padding(
                          padding: EdgeInsets.only(top: 35),
                          child: Icon(
                            Icons.extension_rounded,
                            size: iconSize,
                          ),
                        ),
                        label: const Text(
                          'Browser Extension',
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const ExtensionDialog(),
                        ),
                      ))),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: PassyPadding(SizedBox(
                      height: 200,
                      child: IconedRectangleButton(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 35),
                          child: SvgPicture.asset(
                            'assets/images/android_logo.svg',
                            width: iconSize,
                          ),
                        ),
                        label: const Text('Android'),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const AndroidDialog(),
                        ),
                      ))),
                ),
                Expanded(
                  child: PassyPadding(SizedBox(
                      height: 200,
                      child: IconedRectangleButton(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 35),
                          child: SvgPicture.asset(
                            'assets/images/linux.svg',
                            width: iconSize,
                          ),
                        ),
                        label: const Text('Linux'),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const LinuxDialog(),
                        ),
                      ))),
                ),
              ],
            ),
            PassyPadding(SizedBox(
                height: 200,
                child: IconedRectangleButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 35),
                    child: SvgPicture.asset(
                      'assets/images/github_icon.svg',
                      width: iconSize,
                    ),
                  ),
                  label: const Text(
                    'More downloads',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => window.open(
                    'https://github.com/GlitterWare/Passy/blob/main/DOWNLOADS.md#downloads',
                    'GitHub',
                  ),
                ))),
          ],
        ),
      ),
    );
  }
}
