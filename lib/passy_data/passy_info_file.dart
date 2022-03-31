import 'dart:io';

import 'json_file.dart';
import 'passy_info.dart';

class PassyInfoFile extends JsonFile<PassyInfo> {
  PassyInfoFile._(File file, {required PassyInfo value})
      : super(file, value: value);

  factory PassyInfoFile(File file) {
    if (file.existsSync()) {
      return PassyInfoFile._(file,
          value: PassyInfo.fromJson(file.readAsStringSync()));
    }
    file.createSync(recursive: true);
    PassyInfoFile _file = PassyInfoFile._(file, value: PassyInfo());
    _file.saveSync();
    return _file;
  }
}
