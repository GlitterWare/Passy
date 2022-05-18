import 'dart:convert';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

const String passyVersion = '0.1.0';

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

  String _encodeRecord(dynamic record) {
    if (record is String) {
      return record
          .replaceAll('\\', '\\\\')
          .replaceAll(',', '\\,')
          .replaceAll('[', '\\[');
    }
    if (record is List) {
      String _encoded = '[';
      if (record.isNotEmpty) {
        for (int i = 0; i < record.length - 1; i++) {
          _encoded += _encodeRecord(record[i]) + ',';
        }
        _encoded += _encodeRecord(record[record.length - 1]);
      }
      _encoded += ']';
      return _encoded;
    }
    return record.toString();
  }

  void _encode(List<List> entry, {String separator = '\n'}) {
    for (List line in entry) {
      List<String> _encodedLine = [];
      if (line.isEmpty) {
        _encoded += separator;
        continue;
      }
      for (dynamic _record in line) {
        _encodedLine.add(_encodeRecord(_record));
      }
      _encoded += _encodedLine.join(',') + separator;
    }
  }

  _encode(object);
  return _encoded;
}

List<List> csvDecode(String source,
    {bool recursive = false, bool decodeBools = false}) {
  List<dynamic> _decode(String source) {
    List<dynamic> _entry = [''];
    int v = 0;
    int _depth = 0;
    Iterator<String> _characters = source.characters.iterator;
    bool _escapeDetected = false;

    void _convert() {
      if (!decodeBools) return;
      if (_entry[v] == 'false') {
        _entry[v] = false;
      }

      if (_entry[v] == 'true') {
        _entry[v] = true;
      }
    }

    while (_characters.moveNext()) {
      if (!_escapeDetected) {
        if (_characters.current == ',') {
          _convert();
          v++;
          _entry.add('');
          continue;
        } else if (_characters.current == '[') {
          _entry[v] += '[';
          _depth++;
          while (_characters.moveNext()) {
            _entry[v] += _characters.current;
            if (_characters.current == ']') {
              _depth--;
              if (_depth == 0) break;
            }
            if (_characters.current == '\\') {
              _escapeDetected = true;
            }
            if (_escapeDetected) {
              _escapeDetected = false;
              continue;
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
        } else if (_characters.current == '\\') {
          _escapeDetected = true;
          continue;
        }
      }

      _entry[v] += _characters.current;
      _escapeDetected = false;
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
