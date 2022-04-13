import 'dart:convert';
import 'dart:math';

import 'package:characters/characters.dart';
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

  void _encode(List<List> entry, {String separator = '\n'}) {
    for (List line in entry) {
      if (line.isEmpty) {
        _encoded += separator;
        continue;
      }
      _encoded += line.join(',').replaceAll(', ', ',') + separator;
    }
  }

  _encode(object);
  return _encoded;
}

List<List> csvDecode(String source, {bool recursive = false}) {
  List<dynamic> _decode(String source) {
    List<dynamic> _entry = [''];
    int v = 0;
    int _depth = 0;
    bool _isString = true;
    Iterator<String> _characters = source.characters.iterator;

    while (_characters.moveNext()) {
      if (_characters.current == '[') {
        _entry[v] += '[';
        _depth++;
        while (_characters.moveNext()) {
          _entry[v] += _characters.current;
          if (_characters.current == ']') {
            _depth--;
            if (_depth == 0) break;
          }
          if (_characters.current == '[') {
            _depth++;
          }
        }
        if (recursive) {
          String _entryString = (_entry[v] as String);
          _isString = false;
          _entry[v] =
              _decode(_entryString.substring(1, _entryString.length - 1));
        }
        continue;
      }

      if (_characters.current == ',') {
        if (_entry[v] == 'false') {
          _entry[v] = false;
        }

        if (_entry[v] == 'true') {
          _entry[v] = true;
        }

        v++;
        _entry.add('');
        _isString = true;
        continue;
      }

      if (_isString) {
        _entry[v] += _characters.current;
        continue;
      }
      (_entry[v] as List<dynamic>).add(_characters.current);
    }

    return _entry;
  }

  List<List> _object = [];

  for (String line in source.split('\n')) {
    if (line.isEmpty) {
      _object.add([]);
      continue;
    }
    _object.add(_decode(line));
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
