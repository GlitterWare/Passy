import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'password.dart';

class Passwords {
  final List<Password> passwords;
  final Encrypter _encrypter;
  final File _file;

  void sort() => passwords.sort((a, b) => a.nickname.compareTo(b.nickname));

  Future<void> save() => _file
      .writeAsString(encrypt(jsonEncode(passwords), encrypter: _encrypter));
  void saveSync() => _file
      .writeAsStringSync(encrypt(jsonEncode(passwords), encrypter: _encrypter));

  Passwords._(
    File file, {
    required Encrypter encrypter,
    required this.passwords,
  })  : _file = file,
        _encrypter = encrypter;

  factory Passwords(File file, {required Encrypter encrypter}) {
    if (file.existsSync()) {
      List<dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return Passwords._(
        file,
        encrypter: encrypter,
        passwords: _json
            .map((e) => Password.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    file.createSync();
    Passwords _passwords = Passwords._(
      file,
      encrypter: encrypter,
      passwords: [],
    );
    _passwords.saveSync();
    return _passwords;
  }
}
