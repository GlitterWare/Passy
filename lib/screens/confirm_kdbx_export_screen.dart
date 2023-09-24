import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:path/path.dart' as path;

import 'export_screen.dart';
import 'log_screen.dart';
import 'main_screen.dart';

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
      showSnackBar(context,
          message: localizations.passwordIsEmpty,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      showSnackBar(context,
          message: localizations.passwordsDoNotMatch,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    try {
      MainScreen.shouldLockScreen = false;
      String? _expFile = await FilePicker.platform.saveFile(
        dialogTitle: localizations.exportPassy,
        lockParentWindow: true,
        fileName:
            'passy-kdbx-export-${_account.username}-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip',
      );
      if (_expFile == null) return;
      File _file = File(_expFile);
      Navigator.pushNamed(context, SplashScreen.routeName);
      await _account.exportKdbx(
          outputDirectory: _file.parent,
          password: _newPassword,
          fileName: path.basename(_file.path));
      Navigator.pop(context);
      Navigator.pop(context);
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
    Future.delayed(const Duration(seconds: 2))
        .then((value) => MainScreen.shouldLockScreen = true);
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
