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
import 'package:path_provider/path_provider.dart';

import 'export_screen.dart';
import 'log_screen.dart';

class ConfirmKdbxExportScreenArgs {
  final bool fileExportEnabled;

  const ConfirmKdbxExportScreenArgs({
    this.fileExportEnabled = true,
  });
}

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

  void _onConfirmPressed(bool fileExportEnabled) async {
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
        _expFile = (await getTemporaryDirectory()).path +
            Platform.pathSeparator +
            fileName;
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
      try {
        await _account.exportKdbx(
            outputDirectory: _file.parent,
            password: _newPassword,
            fileName: path.basename(_file.path),
            fileExportEnabled: fileExportEnabled);
      } finally {
        if (Platform.isAndroid) {
          try {
            await FilePicker.platform.saveFile(
              dialogTitle: localizations.exportPassy,
              lockParentWindow: true,
              fileName: fileName,
              bytes: File(_expFile).readAsBytesSync(),
            );
          } finally {
            await File(_expFile).delete();
          }
        }
      }
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
    ConfirmKdbxExportScreenArgs args = ModalRoute.of(context)!
        .settings
        .arguments as ConfirmKdbxExportScreenArgs;
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
                        onFieldSubmitted: (s) =>
                            _onConfirmPressed(args.fileExportEnabled),
                        onPressed: () =>
                            _onConfirmPressed(args.fileExportEnabled),
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
