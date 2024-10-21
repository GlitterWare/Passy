import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/screens/unlock_screen.dart';
import 'package:path/path.dart' as path;

import 'export_screen.dart';
import 'log_screen.dart';

class ConfirmKdbxExportScreen extends StatefulWidget {
  static const String routeName = '${ExportScreen.routeName}/kdbx';

  const ConfirmKdbxExportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmKdbxExportScreen();
}

class _ConfirmKdbxExportScreen extends State<ConfirmKdbxExportScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  String _newPassword = '';
  String _newPasswordConfirm = '';

  void _onConfirmPressed() async {
    if (_newPassword.isEmpty) {
      showSnackBar(
        message: localizations.passwordIsEmpty,
        icon: const Icon(Icons.lock_rounded),
      );
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      showSnackBar(
        message: localizations.passwordsDoNotMatch,
        icon: const Icon(Icons.lock_rounded),
      );
      return;
    }
    try {
      UnlockScreen.shouldLockScreen = false;
      String fileName =
          'passy-kdbx-export-${_account.username}-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
      String? _expFile;
      if (Platform.isAndroid) {
        String? expDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: localizations.exportPassy,
          lockParentWindow: true,
        );
        if (expDir != null) {
          _expFile = expDir + Platform.pathSeparator + fileName;
        }
      } else {
        _expFile = await FilePicker.platform.saveFile(
          dialogTitle: localizations.exportPassy,
          lockParentWindow: true,
          fileName: fileName,
        );
      }
      if (_expFile == null) return;
      File _file = File(_expFile);
      Navigator.pushNamed(context, SplashScreen.routeName);
      await _account.exportKdbx(
          outputDirectory: _file.parent,
          password: _newPassword,
          fileName: path.basename(_file.path));
      Navigator.pop(context);
      Navigator.pop(context);
      showSnackBar(
        message: localizations.exportSaved,
        icon: const Icon(Icons.ios_share_rounded),
      );
    } catch (e, s) {
      if (e is FileSystemException) {
        showSnackBar(
          message: localizations.accessDeniedTryAnotherFolder,
          icon: const Icon(Icons.ios_share_rounded),
        );
      } else {
        showSnackBar(
          message: localizations.couldNotExport,
          icon: const Icon(Icons.ios_share_rounded),
          action: SnackBarAction(
            label: localizations.details,
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        );
      }
    }
    Future.delayed(const Duration(seconds: 2))
        .then((value) => UnlockScreen.shouldLockScreen = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.kdbxExport),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              const Spacer(),
              Expanded(
                child: PassyPadding(
                  Column(
                    children: [
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: localizations.password),
                        obscureText: true,
                        onChanged: (s) => setState(() => _newPassword = s),
                      ),
                      ButtonedTextFormField(
                        labelText: localizations.confirmPassword,
                        obscureText: true,
                        onChanged: (s) =>
                            setState(() => _newPasswordConfirm = s),
                        onFieldSubmitted: (s) => _onConfirmPressed(),
                        onPressed: _onConfirmPressed,
                        buttonIcon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
