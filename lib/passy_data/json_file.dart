import 'dart:convert';

import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/encrypted_json_file.dart';

import 'json_convertable.dart';
import 'saveable_file_base.dart';

class JsonFile<T extends JsonConvertable> with SaveableFileBase {
  final T value;
  final File _file;
  final T Function(Map<String, dynamic> json) _fromJson;

  JsonFile(
    this._file, {
    required T Function(Map<String, dynamic> json) fromJson,
    required this.value,
  }) : _fromJson = fromJson;

  factory JsonFile.fromFile(
    File file, {
    required T Function() constructor,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (file.existsSync()) {
      return JsonFile<T>(
        file,
        fromJson: fromJson,
        value: fromJson(jsonDecode(file.readAsStringSync())),
      );
    }
    file.createSync(recursive: true);
    JsonFile<T> _file = JsonFile<T>(
      file,
      fromJson: fromJson,
      value: constructor(),
    );
    _file.saveSync();
    return _file;
  }

  @override
  Future<void> save() => _file.writeAsString(jsonEncode(value));
  @override
  void saveSync() => _file.writeAsStringSync(jsonEncode(value));

  EncryptedJsonFile<T> toEncryptedJSONFile(Encrypter encrypter) =>
      EncryptedJsonFile<T>(
        _file,
        encrypter: encrypter,
        fromJson: _fromJson,
        value: value,
      );
}
