import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'backup_and_restore_screen.dart';
import 'login_screen.dart';
import 'log_screen.dart';
import 'main_screen.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({Key? key}) : super(key: key);

  static const routeName = '${BackupAndRestoreScreen.routeName}/restore';

  @override
  State<StatefulWidget> createState() => _RestoreScreen();
}

class _RestoreScreen extends State<RestoreScreen> {
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
        title: const Text('Restore'),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: const Text('Passy restore'),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              logoCircleSvg,
              width: 30,
              color: PassyTheme.lightContentColor,
            ),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () {
            FilePicker.platform.pickFiles(
              dialogTitle: 'Restore passy backup',
              type: FileType.custom,
              allowedExtensions: ['zip'],
            ).then(
              (_pick) {
                if (_pick == null) return;
                Navigator.pushNamed(
                  context,
                  ConfirmStringScreen.routeName,
                  arguments: ConfirmStringScreenArguments(
                    title: const Text('Passy restore'),
                    message: PassyPadding(RichText(
                      text: const TextSpan(
                        text:
                            'If the account you\'re restoring already exists, then ',
                        children: [
                          TextSpan(
                            text: 'its current data will be lost ',
                            style: TextStyle(
                                color: PassyTheme.lightContentSecondaryColor),
                          ),
                          TextSpan(
                              text:
                                  'and replaced with the backup.\n\nEnter account password to restore.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )),
                    labelText: 'Enter password',
                    obscureText: true,
                    confirmIcon:
                        const Icon(Icons.settings_backup_restore_rounded),
                    onBackPressed: (context) => Navigator.pop(context),
                    onConfirmPressed: (context, value) {
                      data
                          .restoreAccount(_pick.files[0].path!,
                              encrypter: getPassyEncrypter(value))
                          .then(
                        (value) {
                          Navigator.popUntil(
                              context,
                              (route) =>
                                  route.settings.name == MainScreen.routeName);
                          Navigator.pushReplacementNamed(
                              context, LoginScreen.routeName);
                        },
                        onError: (e, s) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(
                                content: Row(children: const [
                                  Icon(Icons.settings_backup_restore_rounded,
                                      color: PassyTheme.darkContentColor),
                                  SizedBox(width: 20),
                                  Text('Could not restore account'),
                                ]),
                                action: SnackBarAction(
                                  label: 'Details',
                                  onPressed: () => Navigator.pushNamed(
                                      context, LogScreen.routeName,
                                      arguments:
                                          e.toString() + '\n' + s.toString()),
                                ),
                              ),
                            );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}
