import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'common.dart';
import 'log_screen.dart';

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
  UniqueKey _fileWidgetKey = UniqueKey();
  PassyFileScreenArgs? _args;

  Future<void> _onExportPressed(PassyFileScreenArgs args) async {
    UnlockScreen.shouldLockScreen = false;
    String? expFile;
    if (Platform.isAndroid) {
      String? expDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: localizations.exportPassy,
        lockParentWindow: true,
      );
      if (expDir != null) {
        expFile = expDir + Platform.pathSeparator + args.title;
      }
    } else {
      expFile = await FilePicker.platform.saveFile(
        dialogTitle: localizations.exportPassy,
        lockParentWindow: true,
        fileName: args.title,
      );
    }
    Future.delayed(const Duration(seconds: 2))
        .then((value) => UnlockScreen.shouldLockScreen = true);
    if (expFile == null) return;
    Navigator.pushNamed(context, SplashScreen.routeName);
    await Future.delayed(const Duration(milliseconds: 200));
    await _account.exportFile(args.key, file: File(expFile));
    Navigator.pop(context);
    showSnackBar(
      message: localizations.exportSaved,
      icon: const Icon(Icons.ios_share_rounded),
    );
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
                  style: TextStyle(
                      color: PassyTheme.of(context)
                          .highlightContentSecondaryColor),
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

  Future<void> _onEditPressed(PassyFileScreenArgs args) async {
    EditFileDialogResponse? response = await showDialog(
        context: context,
        builder: (_) => EditFileDialog(name: args.title, type: args.type));
    if (response == null) return;
    PassyFileType? type = passyFileTypeFromFileEntryType(response.type);
    Navigator.pushNamed(context, SplashScreen.routeName);
    await Future.delayed(const Duration(milliseconds: 200));
    if (type != null) {
      if (response.type != args.type) {
        _account.changeFileType(args.key, type: type);
      }
    }
    if (response.name != args.title) {
      _account.renameFile(args.key, name: response.name);
    }
    setState(() {
      _args = PassyFileScreenArgs(
          title: response.name, key: args.key, type: response.type);
    });
    _fileWidgetKey = UniqueKey();
    await Future.delayed(const Duration(milliseconds: 200));
    Navigator.pop(context);
    showSnackBar(
      message: localizations.fileSaved,
      icon: const Icon(Icons.edit_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    PassyFileScreenArgs args = _args ??
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
            onPressed: () => setState(() => _fileWidgetKey = UniqueKey()),
            tooltip: localizations.refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            tooltip: localizations.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _onEditPressed(args),
          ),
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
      ),
      body: CustomScrollView(
        physics: args.type == FileEntryType.photo
            ? const NeverScrollableScrollPhysics()
            : null,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              children: [
                if (args.type == FileEntryType.photo) const Spacer(),
                Flexible(
                  child: PassyPadding(PassyFileWidget(
                    key: _fileWidgetKey,
                    path: args.key,
                    name: args.title,
                    isEncrypted: true,
                    type: args.type,
                  )..errorStream.listen((e) {
                      showSnackBar(
                        message: localizations.somethingWentWrong,
                        icon: const Icon(Icons.error_outline_rounded),
                        action: SnackBarAction(
                          label: localizations.details,
                          onPressed: () => Navigator.pushNamed(
                              navigatorKey.currentContext!, LogScreen.routeName,
                              arguments: e.toString()),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        if (!mounted) return;
                        setState(() => _fileWidgetKey = UniqueKey());
                      });
                    })),
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
