import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path_lib;
import 'package:xdg_directories/xdg_directories.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
late PassyData data;
late AppLocalizations localizations;

Future<Directory> getDocumentsDirectory() async {
  if (Platform.isLinux) {
    {
      Directory? xdgDir = getUserDirectory('DOCUMENTS');
      if (xdgDir != null) {
        try {
          if (!await xdgDir.exists()) {
            await xdgDir.create(recursive: true);
          }
          return xdgDir;
        } catch (_) {}
      }
    }

    Directory documentsDir;

    Future<Directory> createFallback() async {
      documentsDir = Directory(path_lib.join(
        (Platform.environment['HOME'] ??
            path_lib.join(
              '/',
              'home',
              Platform.environment['USER'],
            )),
        'Documents',
      ));
      if (!(await documentsDir.exists())) {
        await documentsDir.create(recursive: true);
      }
      return documentsDir;
    }

    try {
      documentsDir = await getApplicationDocumentsDirectory();
    } catch (_) {
      return createFallback();
    }
    if (!(await documentsDir.exists())) return createFallback();
    return documentsDir;
  }
  return await getApplicationDocumentsDirectory();
}

Future<PassyData> loadPassyData() async {
  return PassyData(
      (await getDocumentsDirectory()).path + Platform.pathSeparator + 'Passy');
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
