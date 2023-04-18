import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
late PassyData data;
late AppLocalizations localizations;

Future<PassyData> loadPassyData() async {
  return PassyData((await getApplicationDocumentsDirectory()).path +
      Platform.pathSeparator +
      'Passy');
}

void loadLocalizations(BuildContext context) {
  localizations = AppLocalizations.of(context)!;
}

Future<String> getLatestVersion() async {
  try {
    String _version = (jsonDecode(await http.read(
      Uri.https('api.github.com', 'repositories/469494355/releases/latest'),
    ))['tag_name'] as String);
    if (_version[0] == 'v') {
      _version = _version.substring(1);
    }
    return _version;
  } catch (_) {
    return passyVersion;
  }
}
