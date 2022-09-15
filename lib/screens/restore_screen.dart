import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/confirm_restore_screen.dart';
import 'package:passy/screens/main_screen.dart';

import 'backup_and_restore_screen.dart';

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
            MainScreen.shouldLockScreen = false;
            FilePicker.platform.pickFiles(
              dialogTitle: 'Restore passy backup',
              type: FileType.custom,
              allowedExtensions: ['zip'],
            ).then(
              (_pick) {
                MainScreen.shouldLockScreen = true;
                if (_pick == null) return;
                Navigator.pushNamed(
                  context,
                  ConfirmRestoreScreen.routeName,
                  arguments: _pick.files[0].path,
                );
              },
            );
          },
        )),
      ]),
    );
  }
}
