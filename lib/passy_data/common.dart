import 'dart:convert';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

const String passyVersion = '0.3.1';

final Random random = Random.secure();

void copyDirectorySync(Directory source, Directory destination) {
  destination.createSync(recursive: true);
  source.listSync(recursive: false).forEach((var entity) {
    if (entity is Directory) {
      var newDirectory = Directory(
          path.join(destination.absolute.path, path.basename(entity.path)));
      newDirectory.createSync();

      copyDirectorySync(entity.absolute, newDirectory);
    } else if (entity is File) {
      entity.copySync(path.join(destination.path, path.basename(entity.path)));
    }
  });
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    if (entity is Directory) {
      var newDirectory = Directory(
          path.join(destination.absolute.path, path.basename(entity.path)));
      await newDirectory.create();
      await copyDirectory(entity.absolute, newDirectory);
    } else if (entity is File) {
      await entity
          .copy(path.join(destination.path, path.basename(entity.path)));
    }
  }
}

bool? boolFromString(String value) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  return null;
}

Encrypter getPassyEncrypter(String password) {
  if (password.length > 32) {
    throw Exception('Password is longer than 32 characters');
  }
  int a = 32 - password.length;
  password += ' ' * a;
  return Encrypter(AES(Key.fromUtf8(password)));
}

Digest getPassyHash(String value) => sha512.convert(utf8.encode(value));

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

String csvEncode(List object) {
  String _encode(dynamic record) {
    if (record is String) {
      return record
          .replaceAll('\\', '\\\\')
          .replaceAll('\n', '\\n')
          .replaceAll(',', '\\,')
          .replaceAll('[', '\\[');
    }
    if (record is List) {
      String _encoded = '[';
      if (record.isNotEmpty) {
        for (int i = 0; i < record.length - 1; i++) {
          _encoded += _encode(record[i]) + ',';
        }
        _encoded += _encode(record[record.length - 1]);
      }
      _encoded += ']';
      return _encoded;
    }
    return record.toString();
  }

  String _result = '';
  if (object.isNotEmpty) {
    for (int i = 0; i < object.length - 1; i++) {
      _result += _encode(object[i]) + ',';
    }
    _result += _encode(object[object.length - 1]);
  }
  return _result;
}

List csvDecode(String source,
    {bool recursive = false, bool decodeBools = false}) {
  List _decode(String source) {
    if (source == '') return [];

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
      String _currentCharacter = _characters.current;

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
      } else {
        if (_characters.current == 'n') {
          _currentCharacter = '\n';
        }
      }

      _entry[v] += _currentCharacter;
      _escapeDetected = false;
    }

    _convert();

    return _entry;
  }

  return _decode(source);
}
