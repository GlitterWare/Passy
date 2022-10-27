import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/screens/main_screen.dart';

import 'export_and_import_screen.dart';
import 'log_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  static const routeName = '${ExportAndImportScreen.routeName}/export';

  @override
  State<StatefulWidget> createState() => _ExportScreen();
}

class _ExportScreen extends State<ExportScreen> {
  Future<bool?> _showExportWarningDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm export'),
        content: RichText(
          text: const TextSpan(
            text: 'When exported, account data becomes ',
            children: [
              TextSpan(
                  text: 'unencrypted',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor)),
              TextSpan(
                  text:
                      '.\n\nIf your export falls into the wrong hands, all your information saved in Passy will be endangered.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: PassyTheme.lightContentSecondaryColor),
              )),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Confirm',
                style: TextStyle(color: PassyTheme.lightContentSecondaryColor),
              )),
        ],
      ),
    );
  }

  Future<void> _onPassyExport(String username) async {
    MainScreen.shouldLockScreen = false;
    try {
      bool? _isConfirmed = await _showExportWarningDialog();
      if (_isConfirmed != true) return;
      String? _expDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Export Passy',
        lockParentWindow: true,
      );
      if (_expDir == null) return;
      await data.exportLoadedAccount(outputDirectoryPath: _expDir);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(children: const [
            Icon(Icons.ios_share_rounded, color: PassyTheme.darkContentColor),
            SizedBox(width: 20),
            Text('Export saved'),
          ]),
        ));
    } catch (e, s) {
      if (e is FileSystemException) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.ios_share_rounded, color: PassyTheme.darkContentColor),
              SizedBox(width: 20),
              Text('Access denied, try another folder'),
            ]),
          ));
      } else {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.ios_share_rounded, color: PassyTheme.darkContentColor),
              SizedBox(width: 20),
              Text('Could not export'),
            ]),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                  arguments: e.toString() + '\n' + s.toString()),
            ),
          ));
      }
    }
    MainScreen.shouldLockScreen = true;
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
        title: const Text('Export'),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: const Text('Passy export'),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              logoCircleSvg,
              width: 30,
              color: PassyTheme.lightContentColor,
            ),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onPassyExport(_username),
        )),
      ]),
    );
  }
}
