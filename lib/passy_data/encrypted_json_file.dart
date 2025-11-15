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
  IV _iv;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;
  final T Function(Map<String, dynamic> json) _fromJson;

  EncryptedJsonFile(
    this._file, {
    required Encrypter encrypter,
    required T Function(Map<String, dynamic> json) fromJson,
    required this.value,
    IV? iv,
  })  : _encrypter = encrypter,
        _fromJson = fromJson,
        _iv = iv ?? IV.fromSecureRandom(16);

  factory EncryptedJsonFile.fromFile(
    File file, {
    required Encrypter encrypter,
    required T Function() constructor,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    if (file.existsSync()) {
      IV? iv;
      String encrypted = file.readAsStringSync();
      List<String> split = encrypted.split(',');
      String decrypted;
      if (split.length > 1) {
        iv = IV.fromBase64(split[0]);
        decrypted = decrypt(split[1], encrypter: encrypter, iv: iv);
      } else {
        iv = IV.fromSecureRandom(16);
        decrypted = decrypt(encrypted, encrypter: encrypter);
        encrypted = encrypt(decrypted, encrypter: encrypter, iv: iv);
        file.writeAsStringSync('${iv.base64},$encrypted');
      }
      return EncryptedJsonFile<T>(
        file,
        encrypter: encrypter,
        fromJson: fromJson,
        value: fromJson(jsonDecode(decrypted)),
        iv: iv,
      );
    }
    file.createSync(recursive: true);
    EncryptedJsonFile<T> _file = EncryptedJsonFile<T>(
      file,
      encrypter: encrypter,
      fromJson: fromJson,
      value: constructor(),
      iv: IV.fromSecureRandom(16),
    );
    _file.saveSync();
    return _file;
  }

  Future<void> reload() async {
    String read = await _file.readAsString();
    List<String> split = read.split(',');
    _iv = IV.fromBase64(split[0]);
    read = split[1];
    String encoded = decrypt(read, encrypter: _encrypter, iv: _iv);
    if (encoded.isEmpty) return;
    value = _fromJson(jsonDecode(encoded));
  }

  void reloadSync() {
    String read = _file.readAsStringSync();
    List<String> split = read.split(',');
    _iv = IV.fromBase64(split[0]);
    read = split[1];
    String encoded = decrypt(read, encrypter: _encrypter, iv: _iv);
    if (encoded.isEmpty) return;
    value = _fromJson(jsonDecode(encoded));
  }

  @override
  Future<void> save() {
    _iv = IV.fromSecureRandom(16);
    return _file.writeAsString(
        '${_iv.base64},${encrypt(jsonEncode(value), encrypter: _encrypter, iv: _iv)}');
  }

  @override
  void saveSync() {
    _iv = IV.fromSecureRandom(16);
    _file.writeAsStringSync(
        '${_iv.base64},${encrypt(jsonEncode(value), encrypter: _encrypter, iv: _iv)}');
  }
}
