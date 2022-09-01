import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'assets.dart';
import '../common/theme.dart';
import 'backup_and_restore_screen.dart';
import 'login_screen.dart';
import 'log_screen.dart';
import 'main_screen.dart';
import 'confirm_string_screen.dart';

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Restore'),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: const Text('Passy restore'),
          left: SvgPicture.asset(
            logoCircleSvg,
            width: 25,
            color: lightContentColor,
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
                      text: TextSpan(
                        text:
                            'If the account you\'re restoring already exists, then ',
                        children: [
                          TextSpan(
                            text: 'its current data will be lost ',
                            style: TextStyle(color: lightContentSecondaryColor),
                          ),
                          const TextSpan(
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
                                content: Row(children: [
                                  Icon(Icons.settings_backup_restore_rounded,
                                      color: darkContentColor),
                                  const SizedBox(width: 20),
                                  const Text('Could not restore account'),
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
