import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_app_theme.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';

class ThemeScreen extends StatefulWidget {
  static const routeName = '/theme';

  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThemeScreen();
}

class _ThemeScreen extends State<ThemeScreen> {
  final LoadedAccount loadedAccount = data.loadedAccount!;

  Future<void> setTheme(PassyAppTheme? theme) async {
    if (theme == null) return;
    setState(() {
      loadedAccount.appTheme = theme;
      loadedAccount.saveLocalSettings();
      loadedAccount.saveHistory();
    });
    await loadedAccount.saveLocalSettings();
    switchAppTheme(context, theme);
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
        title: Text(localizations.theme),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          PassyPadding(EnumDropDownButtonFormField(
            value: loadedAccount.appTheme,
            values: PassyAppTheme.values,
            onChanged: setTheme,
          )),
        ],
      ),
    );
  }
}
