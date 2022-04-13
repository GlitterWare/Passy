import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/saveable_file_base.dart';
import 'package:universal_io/io.dart';

class JsonFile<T extends JsonConvertable> implements SaveableFileBase {
  final T value;
  final File _file;

  JsonFile(this._file, {required this.value});

  factory JsonFile.fromFile(
    File file, {
    required T Function() constructor,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (file.existsSync()) {
      return JsonFile<T>(
        file,
        value: fromJson(jsonDecode(file.readAsStringSync())),
      );
    }
    file.createSync(recursive: true);
    JsonFile<T> _file = JsonFile<T>(file, value: constructor());
    _file.saveSync();
    return _file;
  }

  @override
  Future<void> save() => _file.writeAsString(jsonEncode(value));
  @override
  void saveSync() => _file.writeAsStringSync(jsonEncode(value));
}
