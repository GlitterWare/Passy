import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/splash_screen.dart';
import 'common.dart';
import 'csv_import_screen.dart';
import 'log_screen.dart';

class CSVImportEntriesScreenArguments {
  Widget title;
  EntryType entryType;
  Map<String, dynamic> entryJson;
  List<List<String>> entries;

  CSVImportEntriesScreenArguments({
    required this.title,
    required this.entryType,
    required this.entryJson,
    required this.entries,
  });
}

class CSVImportEntriesScreen extends StatefulWidget {
  const CSVImportEntriesScreen({Key? key}) : super(key: key);

  static const routeName = '${CSVImportScreen.routeName}/entries';

  @override
  State<StatefulWidget> createState() => _CSVImportEntriesScreen();
}

class _CSVImportEntriesScreen extends State<CSVImportEntriesScreen> {
  List<String> csvToJson = [];
  List<DropdownMenuItem<String>> entryJsonKeys = [
    DropdownMenuItem(
      child: Text(localizations.none),
      value: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    CSVImportEntriesScreenArguments args = ModalRoute.of(context)!
        .settings
        .arguments as CSVImportEntriesScreenArguments;
    //List<String> entryJsonKeys = jsonToCSV.keys.toList();
    String defaultEntry;
    switch (args.entryType) {
      case EntryType.password:
        defaultEntry = 'additionalInfo';
        break;
      case EntryType.paymentCard:
        defaultEntry = 'additionalInfo';
        break;
      case EntryType.note:
        defaultEntry = 'note';
        break;
      case EntryType.idCard:
        defaultEntry = 'additionalInfo';
        break;
      case EntryType.identity:
        defaultEntry = 'additionalInfo';
        break;
    }
    if (csvToJson.isEmpty) {
      if (args.entries.isNotEmpty) {
        List<String> entry = args.entries.first;
        for (int i = 0; i != entry.length; i++) {
          dynamic entryValue = entry[i];
          if (entryValue is! String) continue;
          csvToJson.add(defaultEntry);
        }
      }
    }
    if (entryJsonKeys.length == 1) {
      for (MapEntry<String, dynamic> entryJsonEntry in args.entryJson.entries) {
        dynamic entryJsonValue = entryJsonEntry.value;
        if (entryJsonValue is! String) continue;
        String entryJsonKey = entryJsonEntry.key;
        if (entryJsonKey == 'iconName') continue;
        if (entryJsonKey == 'key') continue;
        String name = entryJsonKey;
        switch (entryJsonKey) {
          case 'additionalInfo':
            name = localizations.additionalInfo;
            break;
          case 'nickname':
            name = localizations.nickname;
            break;
          case 'username':
            name = localizations.username;
            break;
          case 'email':
            name = localizations.email;
            break;
          case 'password':
            name = localizations.password;
            break;
          case 'website':
            name = localizations.website;
            break;
          case 'cardNumber':
            name = localizations.cardNumber;
            break;
          case 'cardholderName':
            name = localizations.cardHolderName;
            break;
          case 'cvv':
            name = 'CVV';
            break;
          case 'exp':
            name = localizations.expirationDate;
            break;
          case 'title':
            name = localizations.title;
            break;
          case 'note':
            name = localizations.note;
            break;
          case 'type':
            name = localizations.type;
            break;
          case 'idNumber':
            name = localizations.idNumber;
            break;
          case 'name':
            name = localizations.name;
            break;
          case 'issDate':
            name = localizations.dateOfIssue;
            break;
          case 'expDate':
            name = localizations.expirationDate;
            break;
          case 'firstName':
            name = localizations.firstName;
            break;
          case 'middleName':
            name = localizations.middleName;
            break;
          case 'lastName':
            name = localizations.lastName;
            break;
          case 'gender':
            name = localizations.gender;
            break;
          case 'number':
            name = localizations.phoneNumber;
            break;
          case 'firstAddressLine':
            name = localizations.firstAddresssLine;
            break;
          case 'secondAddressLine':
            name = localizations.secondAddressLine;
            break;
          case 'zipCode':
            name = localizations.zipCode;
            break;
          case 'city':
            name = localizations.city;
            break;
          case 'country':
            name = localizations.country;
            break;
        }
        entryJsonKeys.add(DropdownMenuItem(
          child: Text(name),
          value: entryJsonKey,
        ));
      }
    }
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: args.title,
          centerTitle: true,
        ),
        body: ListView(children: [
          PassyPadding(Text(
            '${localizations.csvImportMessage1}.\n\n${localizations.csvImportMessage2}.',
            textAlign: TextAlign.center,
          )),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return PassyPadding(DropdownButtonFormField<String>(
                value: csvToJson[index],
                items: entryJsonKeys,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    csvToJson[index] = value;
                  });
                },
                decoration:
                    InputDecoration(labelText: args.entries.first[index]),
              ));
            },
            itemCount: csvToJson.length,
          ),
          PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.download_for_offline_outlined),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: Text(localizations.import),
              onPressed: () async {
                if (args.entries.length == 1) return;
                Navigator.pushNamed(context, SplashScreen.routeName);
                List<PassyEntry> result = [];
                DateTime _now = DateTime.now().toUtc();
                for (int i = 1; i != args.entries.length; i++) {
                  Map<String, dynamic> jsonResult =
                      args.entryJson.map((key, value) => MapEntry(key, value));
                  jsonResult['key'] = '${_now.toIso8601String()}-import-$i';
                  for (int j = 0; j != csvToJson.length; j++) {
                    String value = csvToJson[j];
                    dynamic jsonValue = jsonResult[value];
                    if (jsonValue is String) {
                      if (jsonValue.isEmpty) {
                        jsonResult[value] = args.entries[i][j];
                      } else {
                        jsonResult[value] += '   ' + args.entries[i][j];
                      }
                    }
                  }
                  PassyEntry entryDecoded;
                  try {
                    entryDecoded =
                        PassyEntry.fromJson(args.entryType)(jsonResult);
                  } catch (e, s) {
                    Navigator.pop(context);
                    showSnackBar(
                      context,
                      message: localizations.couldNotImportAccount,
                      icon: const Icon(Icons.download_for_offline_outlined,
                          color: PassyTheme.darkContentColor),
                      action: SnackBarAction(
                        label: localizations.details,
                        onPressed: () => Navigator.pushNamed(
                            context, LogScreen.routeName,
                            arguments: e.toString() + '\n' + s.toString()),
                      ),
                    );
                    return;
                  }
                  result.add(entryDecoded);
                }
                Future<void> Function(List<PassyEntry<dynamic>>) setEntries =
                    data.loadedAccount!.setEntries(args.entryType);
                setEntries(result);
                Navigator.pop(context);
                Navigator.pop(context);
              })),
        ]));
  }
}
