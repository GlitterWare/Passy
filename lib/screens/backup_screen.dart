import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/widgets/three_widget_button.dart';
import 'package:passy/widgets/passy_back_button.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '/main/backupAndRestore/backup';

  @override
  State<StatefulWidget> createState() => _BackupScreen();
}

class _BackupScreen extends State<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Backup'),
        centerTitle: true,
      ),
      body: ListView(children: [
        ThreeWidgetButton(
          center: const Text('Passy backup'),
          left: SvgPicture.asset(
            logoCircleSvg,
            width: 25,
            color: lightContentColor,
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => FilePicker.platform
              .getDirectoryPath(dialogTitle: 'Backup passy')
              .then((buDir) {
            if (buDir == null) return;
            data.backupAccount(_username, buDir);
          }),
        ),
      ]),
    );
  }
}
