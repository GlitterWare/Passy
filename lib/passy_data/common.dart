import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

const String passyVersion = '1.4.1';
const String syncVersion = '2.0.0';
const String accountVersion = '2.2.0';

/// Returns false if version2 is lower, true if version2 is higher and null if both versions are the same
bool? compareVersions(version1, version2) {
  List<int> version1Split =
      version1.split('.').map<int>((str) => int.parse(str)).toList();
  List<int> version2Split =
      version2.split('.').map<int>((str) => int.parse(str)).toList();
  if (version2Split[0] < version1Split[0]) return false;
  if (version2Split[0] > version1Split[0]) return true;
  if (version2Split[1] < version1Split[1]) return false;
  if (version2Split[1] > version1Split[1]) return true;
  if (version2Split[2] < version1Split[2]) return false;
  if (version2Split[2] > version1Split[2]) return true;
  return null;
}

bool isLineDelimiter(String priorChar, String char, String lineDelimiter) {
  if (lineDelimiter.length == 1) {
    return char == lineDelimiter;
  }
  return '$priorChar$char' == lineDelimiter;
}

/// Reads one line and returns its contents.
///
/// If end-of-file has been reached and the line is empty null is returned.
String? readLine(RandomAccessFile raf,
    {String lineDelimiter = '\n', void Function()? onEOF}) {
  String line = '';
  int byte;
  String priorChar = '';
  byte = raf.readByteSync();
  while (byte != -1) {
    String char = utf8.decode([byte]);
    if (isLineDelimiter(priorChar, char, lineDelimiter)) return line;
    line += char;
    priorChar = char;
    byte = raf.readByteSync();
  }
  onEOF?.call();
  if (line.isEmpty) return null;
  return line;
}

/// Skips one line and returns the last byte read.
///
/// If end-of-file has been reached -1 is returned.
int skipLine(RandomAccessFile raf,
    {String lineDelimiter = '\n', void Function()? onEOF}) {
  int byte;
  String priorChar = '';
  byte = raf.readByteSync();
  while (byte != -1) {
    String char = utf8.decode([byte]);
    if (isLineDelimiter(priorChar, char, lineDelimiter)) return byte;
    priorChar = char;
    byte = raf.readByteSync();
  }
  return byte;
}

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

String encrypt(String data, {required Encrypter encrypter, IV? iv}) {
  if (data.isEmpty) return '';
  return encrypter
      .encrypt(
        data,
        iv: iv ?? IV.fromLength(16),
      )
      .base64;
}

String decrypt(String data, {required Encrypter encrypter, IV? iv}) {
  if (data.isEmpty) return '';
  return encrypter.decrypt64(
    data,
    iv: iv ?? IV.fromLength(16),
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

/// Reads all lines in the file and executes [onLine] per each.
///
/// If [onLine] returns true the function terminates.
void processLines(
  RandomAccessFile raf, {
  String lineDelimiter = '\n',
  required bool? Function(String line, bool eofReached) onLine,
}) {
  bool _eofReached = false;
  do {
    String? _line;
    _line = readLine(raf,
        lineDelimiter: lineDelimiter, onEOF: () => _eofReached = true);
    if (_line == null) return;
    if (onLine(_line, _eofReached) == true) return;
  } while (!_eofReached);
}

/// Reads all lines in the file and executes [onLine] per each.
///
/// If [onLine] returns true the function terminates.
Future<void> processLinesAsync(
  RandomAccessFile raf, {
  String lineDelimiter = '\n',
  required Future<bool?> Function(String line, bool eofReached) onLine,
}) async {
  bool _eofReached = false;
  do {
    String? _line;
    _line = readLine(raf,
        lineDelimiter: lineDelimiter, onEOF: () => _eofReached = true);
    if (_line == null) return;
    if (await onLine(_line, _eofReached) == true) return;
  } while (!_eofReached);
}
