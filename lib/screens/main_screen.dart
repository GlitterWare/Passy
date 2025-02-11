// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';
import 'package:passy_website/widgets/about_passy_dialog.dart';

import 'common.dart';
import 'downloads_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(children: [
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
        leading: IconButton(
          tooltip: 'GlitterWare',
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: Image.asset('assets/images/gw_transparent.png'),
          onPressed: () =>
              window.open('https://glitterware.github.io', 'GlitterWare'),
        ),
      ),
      body: ListView(
        children: [
          const PassyPadding(
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text:
                    '\nThis page hosts information and downloads for various Passy applications and plugins, as well as a small demo of its UI experience.\n\nFor the full experience, ',
                children: [
                  TextSpan(
                    text:
                        'please click the "Downloads" button found below this text.\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PassyTheme.lightContentSecondaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
          PassyPadding(SizedBox(
              height: buttonHeight,
              child: IconedRectangleButton(
                backgroundColor: PassyTheme.lightContentColor,
                icon: const Padding(
                  padding: EdgeInsets.only(top: iconTopPadding),
                  child: Icon(
                    Icons.download_rounded,
                    size: iconSize,
                    color: PassyTheme.darkContentColor,
                  ),
                ),
                label: const Text('Downloads',
                    style: TextStyle(color: PassyTheme.darkContentColor)),
                onPressed: () =>
                    Navigator.pushNamed(context, DownloadsScreen.routeName),
              ))),
          PassyPadding(SizedBox(
              height: buttonHeight,
              child: IconedRectangleButton(
                icon: const Padding(
                    padding: EdgeInsets.only(top: iconTopPadding),
                    child: Icon(
                      Icons.password,
                      size: iconSize,
                    )),
                label: const Text('Password generator'),
                onPressed: _generatePassword,
              ))),
          Row(
            children: [
              Expanded(
                child: PassyPadding(SizedBox(
                    height: buttonHeight,
                    child: IconedRectangleButton(
                      icon: const Padding(
                        padding: EdgeInsets.only(top: iconTopPadding),
                        child: Icon(
                          Icons.money_rounded,
                          size: iconSize,
                        ),
                      ),
                      label: const Text('Donate'),
                      onPressed: () => window.open(
                          'https://github.com/sponsors/GlitterWare', 'Donate'),
                    ))),
              ),
              Expanded(
                child: PassyPadding(SizedBox(
                    height: buttonHeight,
                    child: IconedRectangleButton(
                      icon: const Padding(
                          padding: EdgeInsets.only(top: iconTopPadding),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: iconSize,
                          )),
                      label: const Text('About'),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const AboutPassyDialog()),
                    ))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
