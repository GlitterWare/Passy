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

String encrypt(String data, {required Encrypter encrypter}) {
  if (data.isEmpty) return '';
  return encrypter
      .encrypt(
        data,
        iv: IV.fromLength(16),
      )
      .base64;
}

String decrypt(String data, {required Encrypter encrypter}) {
  if (data.isEmpty) return '';
  return encrypter.decrypt64(
    data,
    iv: IV.fromLength(16),
  );
}

String csvEncode(List<List> object) {
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

List<List> csvDecode(String source) {
  List<List> _object = [];
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

/// Convert a Json map to a CSV list
/// May not correctly convert json maps that contain maps with map values.
List<List> jsonToCSV(String rootName, Map<String, dynamic> json) {
  List<List> _csv = [];

  void _convert({
    required name,
    required Map<String, dynamic> json,
  }) {
    _csv.add([name]);
    int _index = _csv.length - 1;
    json.forEach((key, value) {
      switch (value.runtimeType) {
        case List<String>:
          List<String> _list = value;
          _list.insert(0, key);
          _csv.add(_list);
          break;
        case Map<String, dynamic>:
          _convert(name: key, json: value);
          break;
        case List<Map<String, dynamic>>:
          for (Map<String, dynamic> map
              in value as List<Map<String, dynamic>>) {
            _convert(name: key, json: map);
          }
          break;
        case Enum:
          _csv[_index].add((value as Enum).name);
          break;
        default:
          _csv[_index].add(value);
          break;
      }
    });
  }

  _convert(name: rootName, json: json);

  return _csv;
}
