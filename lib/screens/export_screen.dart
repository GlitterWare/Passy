import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'package:passy/common/assets.dart';
import 'package:passy/screens/common.dart';
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
        shape: PassyTheme.dialogShape,
        title: Text(localizations.confirmExport),
        content: RichText(
          text: TextSpan(
            text: localizations.confirmExport1,
            children: [
              TextSpan(
                  text: localizations.confirmExport2Highlighted,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor)),
              TextSpan(text: '.\n\n${localizations.confirmImport3}.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                localizations.cancel,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              )),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.confirm,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
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
        dialogTitle: localizations.exportPassy,
        lockParentWindow: true,
      );
      if (_expDir == null) return;
      await data.exportLoadedAccount(outputDirectoryPath: _expDir);
      showSnackBar(context,
          message: localizations.exportSaved,
          icon: const Icon(Icons.ios_share_rounded,
              color: PassyTheme.darkContentColor));
    } catch (e, s) {
      if (e is FileSystemException) {
        showSnackBar(context,
            message: localizations.accessDeniedTryAnotherFolder,
            icon: const Icon(Icons.ios_share_rounded,
                color: PassyTheme.darkContentColor));
      } else {
        showSnackBar(
          context,
          message: localizations.couldNotExport,
          icon: const Icon(Icons.ios_share_rounded,
              color: PassyTheme.darkContentColor),
          action: SnackBarAction(
            label: localizations.details,
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        );
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
        title: Text(localizations.export),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.passyExport),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              logoCircleSvg,
              width: 30,
              colorFilter: const ColorFilter.mode(
                  PassyTheme.lightContentColor, BlendMode.srcIn),
            ),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onPassyExport(_username),
        )),
      ]),
    );
  }
}
