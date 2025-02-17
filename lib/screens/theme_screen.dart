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
  String themeMode = data.loadedAccount!.appTheme.name.contains('Light')
      ? 'Light'
      : data.loadedAccount!.appTheme.name.contains('DarkOLED')
          ? 'DarkOLED'
          : 'Dark';
  UniqueKey colorPickerKey = UniqueKey();

  Future<void> setTheme(PassyAppTheme? theme) async {
    setState(() => loadedAccount.appTheme = theme!);
    await loadedAccount.saveLocalSettings();
    await loadedAccount.saveHistory();
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
            key: colorPickerKey,
            customColorSwatchesAndNames: {
              ColorTools.createPrimarySwatch((themeMode == 'Light'
                      ? PassyTheme.classicLight
                      : PassyTheme.classicDark)
                  .extension<PassyTheme>()!
                  .accentContentColor): 'classic',
              ColorTools.createPrimarySwatch((themeMode == 'Light'
                      ? PassyTheme.emeraldLight
                      : PassyTheme.emeraldDark)
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
                if (themeMode == 'DarkOLED') {
                  setTheme(PassyAppTheme.classicDarkOLED);
                } else {
                  setTheme(PassyAppTheme.classicDark);
                }
              } else if (color ==
                  PassyTheme.classicLight
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                setTheme(PassyAppTheme.classicLight);
              } else if (color ==
                  PassyTheme.emeraldDark
                      .extension<PassyTheme>()!
                      .accentContentColor) {
                if (themeMode == 'DarkOLED') {
                  setTheme(PassyAppTheme.emeraldDarkOLED);
                } else {
                  setTheme(PassyAppTheme.emeraldDark);
                }
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
                value: themeMode == 'Dark',
                onChanged: (bool? value) {
                  setState(() {
                    themeMode = 'Dark';
                    colorPickerKey = UniqueKey();
                  });
                  if (!loadedAccount.appTheme.name.contains('DarkOLED') &&
                      loadedAccount.appTheme.name.contains('Dark')) return;
                  setTheme(passyAppThemeFromName(loadedAccount.appTheme.name
                      .replaceFirst('DarkOLED', 'Dark')
                      .replaceFirst('Light', 'Dark')));
                },
              ),
              const Icon(Icons.dark_mode),
            ])),
            PassyPadding(Column(children: [
              Checkbox(
                value: themeMode == 'Light',
                onChanged: (bool? value) {
                  setState(() {
                    themeMode = 'Light';
                    colorPickerKey = UniqueKey();
                  });
                  if (loadedAccount.appTheme.name.contains('Light')) return;
                  setTheme(passyAppThemeFromName(loadedAccount.appTheme.name
                      .replaceFirst('DarkOLED', 'Light')
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
          PassyPadding(Column(children: [
            Checkbox(
              value: themeMode == 'DarkOLED',
              onChanged: (bool? value) {
                setState(() {
                  themeMode = 'DarkOLED';
                  colorPickerKey = UniqueKey();
                });
                if (loadedAccount.appTheme.name.contains('DarkOLED')) return;
                setTheme(passyAppThemeFromName(loadedAccount.appTheme.name
                    .replaceFirst('Dark', 'DarkOLED')
                    .replaceFirst('Light', 'DarkOLED')));
              },
            ),
            const Text(
              'OLED',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ])),
        ],
      ),
    );
  }
}
