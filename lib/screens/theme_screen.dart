import 'package:flex_color_picker/flex_color_picker.dart';
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
  String themeMode =
      data.loadedAccount!.appTheme.name.contains('Dark') ? 'dark' : 'light';

  Future<void> setTheme(PassyAppTheme? theme) async {
    setState(() {
      loadedAccount.appTheme = theme!;
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
          ColorPicker(
            customColorSwatchesAndNames: {
              ColorTools.createPrimarySwatch((themeMode == 'dark'
                      ? PassyTheme.classicDark
                      : PassyTheme.classicLight)
                  .extension<PassyTheme>()!
                  .accentContentColor): 'classic',
              ColorTools.createPrimarySwatch((themeMode == 'dark'
                      ? PassyTheme.emeraldDark
                      : PassyTheme.emeraldLight)
                  .extension<PassyTheme>()!
                  .accentContentColor): 'emerald',
            },
            pickersEnabled: const {
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
              ColorPickerType.custom: true,
            },
            enableShadesSelection: false,
            onColorChanged: (color) {
              if (color ==
                  PassyTheme.classicDark
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                setTheme(PassyAppTheme.classicDark);
              } else if (color ==
                  PassyTheme.classicLight
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                setTheme(PassyAppTheme.classicLight);
              } else if (color ==
                  PassyTheme.emeraldDark
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                setTheme(PassyAppTheme.emeraldDark);
              } else if (color ==
                  PassyTheme.emeraldLight
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                setTheme(PassyAppTheme.emeraldLight);
              }
            },
          ),
          Row(children: [
            const Spacer(),
            PassyPadding(Column(children: [
              Checkbox(
                value: themeMode == 'dark',
                onChanged: (bool? value) {
                  setState(() {
                    themeMode = 'dark';
                  });
                  if (loadedAccount.appTheme.name.contains('Dark')) return;
                  setTheme(passyAppThemeFromName(loadedAccount.appTheme.name
                      .replaceFirst('Light', 'Dark')));
                },
              ),
              const Icon(Icons.dark_mode),
            ])),
            PassyPadding(Column(children: [
              Checkbox(
                value: themeMode == 'light',
                onChanged: (bool? value) {
                  setState(() {
                    themeMode = 'light';
                  });
                  if (loadedAccount.appTheme.name.contains('Light')) return;
                  setTheme(passyAppThemeFromName(loadedAccount.appTheme.name
                      .replaceFirst('Dark', 'Light')));
                },
              ),
              const Icon(Icons.light_mode),
            ])),
            /*
            PassyPadding(Column(children: [
              Checkbox(
                value: themeMode == 'auto',
                onChanged: (bool? value) {
                  setState(() {
                    themeMode = 'auto';
                    setTheme(null);
                  });
                },
              ),
              const Icon(Icons.auto_fix_high),
            ])),
            */
            const Spacer(),
          ]),
        ],
      ),
    );
  }
}
