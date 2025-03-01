import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/screens/security_screen.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/servers_screen.dart';
import 'package:passy/screens/theme_screen.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'backup_and_restore_screen.dart';
import 'common.dart';
import 'export_and_import_screen.dart';
import 'main_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/settings';

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  void setMinimizeToTray(bool value) {
    if (value) {
      if (!trayEnabled) toggleTray(context);
    } else {
      if (trayEnabled) toggleTray(context);
    }
    setState(() {
      _account.minimizeToTray = value;
    });
    _account.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.donate),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.money_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => openUrl('https://github.com/sponsors/GlitterWare'),
          )),
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
            center: Text(localizations.theme),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.colorize),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, ThemeScreen.routeName),
          )),
          if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
            PassyPadding(ThreeWidgetButton(
              center: Text(localizations.minimizeToTray),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.circle),
              ),
              right: Switch(
                //activeColor: Colors.deepPurpleAccent,
                value: _account.minimizeToTray,
                onChanged: (value) => setMinimizeToTray(value),
              ),
              onPressed: () => setMinimizeToTray(!_account.minimizeToTray),
            )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.backupAndRestore),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.save_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, BackupAndRestoreScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.exportAndImport),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.ios_share_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => Navigator.pushNamed(
                context, ExportAndImportScreen.routeName,
                arguments: data.loadedAccount!.username),
          )),
          PassyPadding(ThreeWidgetButton(
              color: (_account.keyDerivationType == KeyDerivationType.none) &&
                      recommendKeyDerivation
                  ? const Color.fromRGBO(255, 82, 82, 1)
                  : null,
              center: Text(localizations.security),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.lock_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, SecurityScreen.routeName)
                      .then((value) => setState(() {})))),
          PassyPadding(ThreeWidgetButton(
              center: Text(localizations.synchronizationServers),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.desktop_windows_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                if (!data.loadedAccount!.isRSAKeypairLoaded) {
                  showSnackBar(
                    message: localizations.settingUpSynchronization,
                    icon: const Icon(CupertinoIcons.clock_solid),
                  );
                  return;
                }
                Navigator.pushNamed(context, ServersScreen.routeName);
              })),
          PassyPadding(ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: WebsafeSvg.asset(
                'assets/images/github_icon.svg',
                width: 26,
                colorFilter: ColorFilter.mode(
                    PassyTheme.of(context).contentTextColor, BlendMode.srcIn),
              ),
            ),
            center: Text(localizations.requestAFeature),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => openUrl(
              'https://github.com/GlitterWare/Passy/issues',
            ),
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
        ],
      ),
    );
  }
}
