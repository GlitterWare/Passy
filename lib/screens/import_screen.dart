import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/confirm_import_screen.dart';
import 'package:passy/screens/csv_import_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'export_and_import_screen.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({Key? key}) : super(key: key);

  static const routeName = '${ExportAndImportScreen.routeName}/import';

  @override
  State<StatefulWidget> createState() => _ImportScreen();
}

class _ImportScreen extends State<ImportScreen> {
  void _onPassyImportPressed() {
    UnlockScreen.shouldLockScreen = false;
    FilePicker.platform
        .pickFiles(
      dialogTitle: localizations.importFromPassy,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      lockParentWindow: true,
    )
        .then(
      (_pick) {
        Future.delayed(const Duration(seconds: 2))
            .then((value) => UnlockScreen.shouldLockScreen = true);
        if (_pick == null) return;
        Navigator.pushNamed(
          context,
          ConfirmImportScreen.routeName,
          arguments: ConfirmImportScreenArgs(
            path: _pick.files[0].path!,
            importType: ImportType.passy,
          ),
        );
      },
    );
  }

  void _onKdbxImportPressed() {
    UnlockScreen.shouldLockScreen = false;
    FilePicker.platform
        .pickFiles(
      dialogTitle: localizations.kdbxImport,
      type: Platform.isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: Platform.isAndroid ? null : ['kdbx'],
      lockParentWindow: true,
    )
        .then(
      (_pick) {
        Future.delayed(const Duration(seconds: 2))
            .then((value) => UnlockScreen.shouldLockScreen = true);
        if (_pick == null) return;
        Navigator.pushNamed(
          context,
          ConfirmImportScreen.routeName,
          arguments: ConfirmImportScreenArgs(
            path: _pick.files[0].path!,
            importType: ImportType.kdbx,
          ),
        );
      },
    );
  }

  void _onAegisImportPressed() {
    UnlockScreen.shouldLockScreen = false;
    FilePicker.platform
        .pickFiles(
      dialogTitle: localizations.aegisImport,
      type: Platform.isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: Platform.isAndroid ? null : ['json'],
      lockParentWindow: true,
    )
        .then(
      (_pick) {
        Future.delayed(const Duration(seconds: 2))
            .then((value) => UnlockScreen.shouldLockScreen = true);
        if (_pick == null) return;
        Navigator.pushNamed(
          context,
          ConfirmImportScreen.routeName,
          arguments: ConfirmImportScreenArgs(
            path: _pick.files[0].path!,
            importType: ImportType.aegis,
          ),
        );
      },
    );
  }

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
        title: Text(localizations.import),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(
          ThreeWidgetButton(
              center: Text(localizations.csvImport),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.download_for_offline_outlined),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, CSVImportScreen.routeName)),
        ),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.kdbxImport),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.file_copy),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: _onKdbxImportPressed,
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.aegisImport),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.security),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: _onAegisImportPressed,
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.passyImport),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              logoCircleSvg,
              width: 24,
              colorFilter: const ColorFilter.mode(
                  PassyTheme.lightContentColor, BlendMode.srcIn),
            ),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: _onPassyImportPressed,
        )),
      ]),
    );
  }
}
