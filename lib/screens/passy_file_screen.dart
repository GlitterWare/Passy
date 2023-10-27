import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class PassyFileScreen extends StatefulWidget {
  static const String routeName = '${FilesScreen.routeName}/file';

  const PassyFileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PassyFileScreen();
}

class PassyFileScreenArgs {
  final String title;
  final String key;
  final FileEntryType type;

  PassyFileScreenArgs({
    required this.title,
    required this.key,
    required this.type,
  });
}

class _PassyFileScreen extends State<StatefulWidget> {
  final LoadedAccount _account = data.loadedAccount!;

  Future<void> _onExportPressed(PassyFileScreenArgs args) async {
    MainScreen.shouldLockScreen = false;
    String? expFile = await FilePicker.platform.saveFile(
      fileName: args.title,
      dialogTitle: localizations.export,
      lockParentWindow: true,
    );
    Future.delayed(const Duration(seconds: 2))
        .then((value) => MainScreen.shouldLockScreen = true);
    if (expFile == null) return;
    Navigator.pushNamed(context, SplashScreen.routeName);
    await Future.delayed(const Duration(milliseconds: 200));
    await _account.exportFile(args.key, file: File(expFile));
    Navigator.pop(context);
  }

  Future<void> _onRemovePressed(PassyFileScreenArgs args) async {
    bool? result = await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removeFile),
            content:
                Text('${localizations.filesCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              )
            ],
          );
        });
    if (result != true) return;
    Navigator.pushNamed(context, SplashScreen.routeName);
    await Future.delayed(const Duration(milliseconds: 200));
    await _account.removeFile(args.key);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    PassyFileScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as PassyFileScreenArgs;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            onPressed: () => _onExportPressed(args),
            tooltip: localizations.export,
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            onPressed: () => _onRemovePressed(args),
            tooltip: localizations.remove,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
        title: Text(args.title),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              children: [
                if (args.type == FileEntryType.photo) const Spacer(),
                Flexible(
                  child: PassyPadding(PassyFileWidget(
                    path: args.key,
                    name: args.title,
                    isEncrypted: true,
                    type: args.type,
                  )),
                  flex: 100,
                ),
                if (args.type == FileEntryType.photo) const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
