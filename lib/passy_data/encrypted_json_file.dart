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
      String encrypted = file.readAsStringSync();
      List<String> split = encrypted.split(',');
      String decrypted;
      if (split.length > 1) {
        final iv = IV.fromBase64(split[0]);
        decrypted = decrypt(split[1], encrypter: encrypter, iv: iv);
      } else {
        final iv = IV.fromSecureRandom(16);
        decrypted = decrypt(encrypted, encrypter: encrypter);
        encrypted = encrypt(decrypted, encrypter: encrypter, iv: iv);
        file.writeAsStringSync('${iv.base64},$encrypted');
      }
      return EncryptedJsonFile<T>(
        file,
        encrypter: encrypter,
        fromJson: fromJson,
        value: fromJson(jsonDecode(decrypted)),
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

  Future<void> reload() async {
    String read = await _file.readAsString();
    if (read.isEmpty) return;
    List<String> split = read.split(',');
    String encoded;
    if (split.length > 1) {
      final iv = IV.fromBase64(split[0]);
      read = split[1];
      encoded = decrypt(read, encrypter: _encrypter, iv: iv);
    } else {
      encoded = decrypt(read, encrypter: _encrypter);
    }
    if (encoded.isEmpty) return;
    value = _fromJson(jsonDecode(encoded));
  }

  void reloadSync() {
    String read = _file.readAsStringSync();
    if (read.isEmpty) return;
    List<String> split = read.split(',');
    String encoded;
    if (split.length > 1) {
      final iv = IV.fromBase64(split[0]);
      read = split[1];
      encoded = decrypt(read, encrypter: _encrypter, iv: iv);
    } else {
      encoded = decrypt(read, encrypter: _encrypter);
    }
    if (encoded.isEmpty) return;
    value = _fromJson(jsonDecode(encoded));
  }

  @override
  Future<void> save() {
    final iv = IV.fromSecureRandom(16);
    return _file.writeAsString(
        '${iv.base64},${encrypt(jsonEncode(value), encrypter: _encrypter, iv: iv)}');
  }

  @override
  void saveSync() {
    final iv = IV.fromSecureRandom(16);
    _file.writeAsStringSync(
        '${iv.base64},${encrypt(jsonEncode(value), encrypter: _encrypter, iv: iv)}');
  }
}
