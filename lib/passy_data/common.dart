import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

const String passyVersion = '0.0.0';

final Random random = Random.secure();

Encrypter getEncrypter(String password) {
  if (password.length > 32) {
    throw Exception('Password is longer than 32 characters');
  }
  int a = 32 - password.length;
  password += ' ' * a;
  return Encrypter(AES(Key.fromUtf8(password)));
}

Digest getHash(String value) => sha512.convert(utf8.encode(value));

String encrypt(String data, {required Encrypter encrypter}) => encrypter
    .encrypt(
      data,
      iv: IV.fromLength(16),
    )
    .base64;

String decrypt(String data, {required Encrypter encrypter}) =>
    encrypter.decrypt64(
      data,
      iv: IV.fromLength(16),
    );

String csvEncode(List<List<dynamic>> object) {
  String _encoded = '';
  for (List<dynamic> line in object) {
    if (line.isEmpty) {
      _encoded += '\n';
      continue;
    }
    _encoded += line.join(',') + '\n';
  }
  return _encoded;
}

List<List<dynamic>> csvDecode(String source) {
  List<List<dynamic>> _object = [];
  List<String> _lines = source.split('\n');
  for (String line in _lines) {
    List<dynamic> _entry;
    if (line.isEmpty) {
      _object.add([]);
      continue;
    }
    _entry = [];
    for (String value in line.split(',')) {
      switch (value) {
        case 'false':
          _entry.add(false);
          break;
        case 'true':
          _entry.add(true);
          break;
        default:
          _entry.add(value);
      }
    }
    _object.add(_entry);
  }
  _object.removeLast();
  return _object;
}
