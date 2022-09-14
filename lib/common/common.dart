import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
late PassyData data;

Future<PassyData> loadPassyData() async {
  return PassyData((await getApplicationDocumentsDirectory()).path +
      Platform.pathSeparator +
      'Passy');
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
