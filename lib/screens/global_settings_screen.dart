import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';

class GlobalSettingsScreen extends StatefulWidget {
  static const String routeName = '/globalSettings';

  const GlobalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GlobalSettingsScreen();
}

class _GlobalSettingsScreen extends State<GlobalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            PassyPadding(
              ThreeWidgetButton(
                center: Text(localizations.enableAutofill),
                left: const Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: Icon(Icons.password_rounded),
                ),
                right: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: () {
                  AutofillService().requestSetAutofillService();
                },
              ),
            ),
          if (!Platform.isAndroid && !Platform.isIOS)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.passyBrowserExtension),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.extension_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () => openUrl(
                  'https://github.com/GlitterWare/Passy-Browser-Extension/blob/main/DOWNLOADS.md'),
            )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.about),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.info_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () {
              showDialog(
                  context: context, builder: (ctx) => const PassyAboutDialog());
            },
          )),
          Center(
              child: Text(
            '${localizations.updatesPopupEnabled}: ${const String.fromEnvironment('UPDATES_POPUP_ENABLED') != 'false'}',
            style: TextStyle(
                color: PassyTheme.of(context).highlightContentSecondaryColor),
          )),
        ],
      ),
    );
  }
}
