import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'dart:io';

import 'common.dart';
import 'json_convertable.dart';
import 'saveable_file_base.dart';

class EncryptedJsonFile<T extends JsonConvertable> with SaveableFileBase {
  T value;
  final File _file;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;
  final T Function(Map<String, dynamic> json) _fromJson;

  EncryptedJsonFile(
    this._file, {
    required Encrypter encrypter,
    required T Function(Map<String, dynamic> json) fromJson,
    required this.value,
  })  : _encrypter = encrypter,
        _fromJson = fromJson;

  factory EncryptedJsonFile.fromFile(
    File file, {
    required Encrypter encrypter,
    required T Function() constructor,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (file.existsSync()) {
      return EncryptedJsonFile<T>(
        file,
        encrypter: encrypter,
        fromJson: fromJson,
        value: fromJson(
            jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter))),
      );
    }
    file.createSync(recursive: true);
    EncryptedJsonFile<T> _file = EncryptedJsonFile<T>(
      file,
      encrypter: encrypter,
      fromJson: fromJson,
      value: constructor(),
    );
    _file.saveSync();
    return _file;
  }

  Future<void> reload() async => value = _fromJson(
      jsonDecode(decrypt(await _file.readAsString(), encrypter: _encrypter)));
  void reloadSync() => value = _fromJson(
      jsonDecode(decrypt(_file.readAsStringSync(), encrypter: _encrypter)));

  @override
  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(value), encrypter: _encrypter));
  @override
  void saveSync() => _file
      .writeAsStringSync(encrypt(jsonEncode(value), encrypter: _encrypter));
}
