import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';

void convertPre1_1_0AccountTo1_1_0({
  required String path,
  required Encrypter encrypter,
}) {
  // Create local settings file
  File(path + Platform.pathSeparator + 'local_settings.json')
      .writeAsStringSync('{"autoBackup":null}');
  // Remove defaultScreen, icon, color from account settings
  {
    File _settingsFile = File(path + Platform.pathSeparator + 'settings.enc');
    Map<String, dynamic> _settingsJson = jsonDecode(
      decrypt(
        _settingsFile.readAsStringSync(),
        encrypter: encrypter,
      ),
    );
    _settingsJson.remove('defaultScreen');
    _settingsJson.remove('icon');
    _settingsJson.remove('color');
    _settingsFile.writeAsStringSync(
        encrypt(jsonEncode(_settingsJson), encrypter: encrypter));
  }
  File(path + Platform.pathSeparator + 'version.txt')
      .writeAsStringSync('1.1.0');
}
