import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/csv_import_entries_screen.dart';
import 'common.dart';
import 'import_screen.dart';
import 'log_screen.dart';
import 'main_screen.dart';

class CSVImportScreen extends StatefulWidget {
  const CSVImportScreen({Key? key}) : super(key: key);

  static const routeName = '${ImportScreen.routeName}/csv';

  @override
  State<StatefulWidget> createState() => _CSVImportScreen();
}

class _CSVImportScreen extends State<CSVImportScreen> {
  void _onImportPressed(
      String title, EntryType entryType, Map<String, dynamic> entryJson) async {
    MainScreen.shouldLockScreen = false;
    FilePickerResult? fileResult;
    try {
      fileResult = await FilePicker.platform.pickFiles(
        dialogTitle: localizations.csvImport,
        type: FileType.any,
        lockParentWindow: true,
      );
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotImportAccount,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    MainScreen.shouldLockScreen = false;
    if (fileResult == null) return;
    if (fileResult.files.isEmpty) return;
    String? filePath = fileResult.files[0].path;
    if (filePath == null) return;
    File file = File(filePath);
    List<String> fileData;
    try {
      fileData = (await file.readAsString()).split('\n');
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotImportAccount,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    List<List<String>> fileDataDecoded = [];
    try {
      for (String line in fileData) {
        List<dynamic> lineDecoded = csvDecode(line);
        List<String> lineDecodedString = [];
        for (dynamic value in lineDecoded) {
          if (value.length > 1) {
            if (value[0] == '"') {
              if (value[value.length - 1] == '"') {
                value = value.substring(1, value.length - 1);
              }
            }
          }
          lineDecodedString.add(value);
        }
        fileDataDecoded.add(lineDecodedString);
      }
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.couldNotImportAccount,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    if (fileDataDecoded.isEmpty) {
      showSnackBar(
        context,
        message: localizations.noCSVDataFound,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      CSVImportEntriesScreen.routeName,
      arguments: CSVImportEntriesScreenArguments(
          title: Text(title),
          entryType: entryType,
          entryJson: entryJson,
          entries: fileDataDecoded),
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
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.importPasswords),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.password_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onImportPressed(
            localizations.importPasswords,
            EntryType.password,
            Password().toJson(),
          ),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.importPaymentCards),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.payment_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onImportPressed(
            localizations.importPaymentCards,
            EntryType.paymentCard,
            PaymentCard().toJson(),
          ),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.importNotes),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.note_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onImportPressed(
            localizations.importNotes,
            EntryType.note,
            Note().toJson(),
          ),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.importIDCards),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.perm_identity_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onImportPressed(
            localizations.importIDCards,
            EntryType.idCard,
            IDCard().toJson(),
          ),
        )),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.importIdentities),
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.people_outline_rounded),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onImportPressed(
            localizations.importIdentities,
            EntryType.identity,
            Identity().toJson(),
          ),
        )),
      ]),
    );
  }
}
