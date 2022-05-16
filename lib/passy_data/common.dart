import 'dart:convert';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

const String passyVersion = '0.0.0';

final Random random = Random.secure();

bool? boolFromString(String value) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  return null;
}

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

List<List> csvDecode(String source,
    {bool recursive = false, bool convertBools = false}) {
  List<dynamic> _decode(String source) {
    List<dynamic> _entry = [''];
    int v = 0;
    int _depth = 0;
    Iterator<String> _characters = source.characters.iterator;

    void _convert() {
      if (!convertBools) return;
      if (_entry[v] == 'false') {
        _entry[v] = false;
      }

      if (_entry[v] == 'true') {
        _entry[v] = true;
      }
    }

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
          if (_entry[v] == '[]') {
            _entry[v] = [];
            continue;
          }
          String _entryString = _entry[v];
          _entry[v] =
              _decode(_entryString.substring(1, _entryString.length - 1));
        }
        continue;
      }

      if (_characters.current == ',') {
        _convert();
        v++;
        _entry.add('');
        continue;
      }

      _entry[v] += _characters.current;
      continue;
    }
    _convert();

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
