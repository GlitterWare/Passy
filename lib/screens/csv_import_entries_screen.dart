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
  @override
  Widget build(BuildContext context) {
    CSVImportEntriesScreenArguments args = ModalRoute.of(context)!
        .settings
        .arguments as CSVImportEntriesScreenArguments;
    Map<String, int> jsonToCSV = {};
    for (MapEntry<String, dynamic> entryJsonEntry in args.entryJson.entries) {
      dynamic entryJsonValue = entryJsonEntry.value;
      if (entryJsonValue is! String) continue;
      String entryJsonKey = entryJsonEntry.key;
      if (entryJsonKey == 'iconName') continue;
      if (entryJsonKey == 'key') continue;
      jsonToCSV[entryJsonKey] = -1;
    }
    List<String> entryJsonKeys = jsonToCSV.keys.toList();
    List<DropdownMenuItem<int>> items = [
      const DropdownMenuItem(
        child: Text('Empty'),
        value: -1,
      ),
    ];
    if (args.entries.isNotEmpty) {
      List<String> entry = args.entries.first;
      for (int i = 0; i != entry.length; i++) {
        dynamic entryValue = entry[i];
        if (entryValue is! String) continue;
        items.add(DropdownMenuItem(
          child: Text(entryValue),
          value: i,
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
            itemBuilder: (context, index) {
              String entryJsonKey = entryJsonKeys[index];
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
              return PassyPadding(DropdownButtonFormField<int>(
                value: -1,
                items: items,
                onChanged: (value) {
                  if (value == null) return;
                  jsonToCSV[entryJsonKey] = value;
                },
                decoration: InputDecoration(labelText: name),
              ));
            },
            itemCount: entryJsonKeys.length,
          ),
          PassyPadding(ThreeWidgetButton(
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.download_for_offline_outlined),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              center: Text(localizations.import),
              onPressed: () async {
                Navigator.pushNamed(context, SplashScreen.routeName);
                List<PassyEntry> result = [];
                DateTime _now = DateTime.now().toUtc();
                int i = 0;
                for (List<dynamic> entry in args.entries) {
                  Map<String, dynamic> jsonResult = {
                    'key': '${_now.toIso8601String()}-import-$i',
                  };
                  for (MapEntry<String, int> jsonToCSVEntry
                      in jsonToCSV.entries) {
                    int index = jsonToCSVEntry.value;
                    if (index == -1) {
                      jsonResult[jsonToCSVEntry.key] = '';
                      continue;
                    }
                    if (index >= entry.length) {
                      jsonResult[jsonToCSVEntry.key] = '';
                      continue;
                    }
                    dynamic entryValue = entry[index];
                    if (entryValue is! String) {
                      jsonResult[jsonToCSVEntry.key] = '';
                      continue;
                    }
                    jsonResult[jsonToCSVEntry.key] = entryValue;
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
                  i++;
                }
                Future<void> Function(PassyEntry<dynamic>) setEntry =
                    data.loadedAccount!.setEntry(args.entryType);
                int setIndex = 0;
                for (PassyEntry entry in result) {
                  await setEntry(entry);
                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            SplashScreen(
                          underLogo: Center(
                              child: PassyPadding(Text(
                                  '${setIndex.toString()}/${result.length}'))),
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ));
                  setIndex++;
                }
                Navigator.pop(context);
                Navigator.pop(context);
              })),
        ]));
  }
}
