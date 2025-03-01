import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/unlock_screen.dart';
import 'package:path/path.dart' as path;

import 'package:passy/screens/common.dart';
import 'package:passy/screens/confirm_kdbx_export_screen.dart';

import 'export_and_import_screen.dart';
import 'log_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  static const routeName = '${ExportAndImportScreen.routeName}/export';

  @override
  State<StatefulWidget> createState() => _ExportScreen();
}

enum _ExportType { passy, csv }

class _ExportScreen extends State<ExportScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  late FormattedTextParser formattedTextParser;
  bool advancedSettingsIsExpanded = false;
  bool fileExportEnabled = true;

  Future<bool?> _showExportWarningDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: PassyTheme.dialogShape,
        title: Text(localizations.confirmExport),
        content: Text.rich(
          formattedTextParser.parse(
              text:
                  '${localizations.confirmExportMsg1}\n\n${localizations.confirmExportMsg2}'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                localizations.cancel,
                style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor),
              )),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.confirm,
                style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor),
              )),
        ],
      ),
    );
  }

  Future<void> _onPassyExport(String username, _ExportType type) async {
    UnlockScreen.shouldLockScreen = false;
    try {
      bool? _isConfirmed = await _showExportWarningDialog();
      if (_isConfirmed != true) return;
      String filename;
      switch (type) {
        case _ExportType.passy:
          filename =
              'passy-export-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
          break;
        case _ExportType.csv:
          filename =
              'passy-csv-export-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
          break;
      }
      String? _expFile;
      if (Platform.isAndroid) {
        String? expDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: localizations.exportPassy,
          lockParentWindow: true,
        );
        if (expDir != null) {
          _expFile = expDir + Platform.pathSeparator + filename;
        }
      } else {
        _expFile = await FilePicker.platform.saveFile(
          dialogTitle: localizations.exportPassy,
          lockParentWindow: true,
          fileName: filename,
        );
      }
      if (_expFile == null) return;
      switch (type) {
        case _ExportType.passy:
          await _account.exportPassy(
              outputDirectory: File(_expFile).parent,
              fileName: path.basename(_expFile),
              fileExportEnabled: fileExportEnabled);
          break;
        case _ExportType.csv:
          await _account.exportCSV(
              outputDirectory: File(_expFile).parent,
              fileName: path.basename(_expFile),
              fileExportEnabled: fileExportEnabled);
          break;
      }
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
  void initState() {
    super.initState();
    formattedTextParser = FormattedTextParser(context: context);
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
          center: Text(localizations.csvExport),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.drive_folder_upload_outlined),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onPassyExport(_username, _ExportType.csv),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.kdbxExport),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.upload_file_outlined),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => Navigator.pushNamed(
              context, ConfirmKdbxExportScreen.routeName,
              arguments: ConfirmKdbxExportScreenArgs(
                  fileExportEnabled: fileExportEnabled)),
        )),
        Padding(
          padding: EdgeInsets.only(
              top: PassyTheme.of(context).passyPadding.top,
              bottom: PassyTheme.of(context).passyPadding.bottom),
          child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) =>
                  setState(() => advancedSettingsIsExpanded = isExpanded),
              elevation: 0,
              dividerColor:
                  PassyTheme.of(context).highlightContentSecondaryColor,
              children: [
                ExpansionPanel(
                    backgroundColor: PassyTheme.of(context).contentColor,
                    isExpanded: advancedSettingsIsExpanded,
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: PassyTheme.of(context).passyPadding.left),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32.0)),
                                  color: PassyTheme.of(context)
                                      .accentContentColor),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 30),
                                    child: Icon(Icons.error_outline_rounded),
                                  ),
                                  Text(localizations.advancedSettings),
                                ],
                              )));
                    },
                    body: Column(
                      children: [
                        PassyPadding(ThreeWidgetButton(
                          center: Text(localizations.files),
                          left: const Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Icon(Icons.description_outlined),
                          ),
                          right: Switch(
                            activeColor: Colors.greenAccent,
                            value: fileExportEnabled,
                            onChanged: (value) =>
                                setState(() => fileExportEnabled = value),
                          ),
                          onPressed: () => setState(
                              () => fileExportEnabled = !fileExportEnabled),
                        )),
                      ],
                    )),
              ]),
        ),
      ]),
    );
  }
}
