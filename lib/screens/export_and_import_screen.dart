import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/settings_screen.dart';

import 'export_screen.dart';
import 'import_screen.dart';

class ExportAndImportScreen extends StatefulWidget {
  static const routeName = '${SettingsScreen.routeName}/exportAndImport';

  const ExportAndImportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExportAndImportScreen();
}

class _ExportAndImportScreen extends State<ExportAndImportScreen> {
  void _onExportPressed(String username) {
    Navigator.pushNamed(context, ExportScreen.routeName, arguments: username);
  }

  void _onImportPressed() {
    Navigator.pushNamed(context, ImportScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.exportAndImport),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.export),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.ios_share_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => _onExportPressed(_username),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.import),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.download_for_offline_outlined),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _onImportPressed,
          )),
        ],
      ),
    );
  }
}
