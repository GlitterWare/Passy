import 'dart:convert';
import 'dart:typed_data';

import 'package:characters/characters.dart';
import 'package:compute/compute.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:encrypt/encrypt.dart';
import 'package:intranet_ip/intranet_ip.dart';
import 'package:passy/passy_data/argon2_info.dart';
import 'package:passy/passy_data/key_derivation_info.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'glare/glare_client.dart';
import 'key_derivation_type.dart';

const String passyVersion = '1.8.0';
const String syncVersion = '2.1.1';
const String accountVersion = '2.4.1';

bool isSnap() {
  return Platform.environment['SNAP_NAME'] == 'passy';
}

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

Future<bool> chmod(List<String> args) async {
  ProcessResult result = Process.runSync('/usr/bin/chmod', args);
  if (result.stderr.isNotEmpty) return false;
  if (result.exitCode > 0) return false;
  return true;
}

Future<bool> setExecutionEnabled(String path, bool permission) {
  return chmod(['${permission ? '+' : '-'}x', path]);
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
  int byteSize = utf8.encode(password).length;
  if (byteSize > 32) {
    throw Exception(
        'Password is longer than 32 bytes. If you\'re using 32 characters, try using 16 and then 8 characters.');
  }
  int a = 32 - byteSize;
  password += ' ' * a;
  return Encrypter(AES(Key.fromUtf8(password)));
}

Encrypter getPassyEncrypterFromBytes(Uint8List password) {
  if (password.length > 32) {
    throw Exception(
        'Password is longer than 32 bytes. If you\'re using 32 characters, try using 16 and then 8 characters.');
  }
  return Encrypter(AES(Key(password)));
}

Future<DArgon2Result> argon2ifyString(
  String s, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2.hashPasswordString(
    s,
    salt: salt,
    parallelism: parallelism,
    memory: memory,
    iterations: iterations,
    length: 32,
  );
  return result;
}

Future<Key> derivePassword(String password,
    {required KeyDerivationType derivationType,
    KeyDerivationInfo? derivationInfo}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      int byteSize = utf8.encode(password).length;
      if (byteSize > 32) {
        throw Exception(
            'Password is longer than 32 bytes. If you\'re using 32 characters, try using 16 and then 8 characters.');
      }
      int a = 32 - byteSize;
      password += ' ' * a;
      return Key.fromUtf8(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return Key(Uint8List.fromList((await argon2ifyString(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      ))
          .rawBytes));
  }
}

Future<Encrypter> getPassyEncrypterV2(
  String password, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2ifyString(password,
      salt: salt,
      parallelism: parallelism,
      memory: memory,
      iterations: iterations);
  return Encrypter(AES(Key(Uint8List.fromList(result.rawBytes))));
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
          .replaceAll('[', '\\[')
          .replaceAll(']', '\\]');
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
            if (_characters.current == '\\') {
              if (!_characters.moveNext()) break;
              _entry[v] += _characters.current;
              continue;
            }
            if (_characters.current == '[') {
              _depth++;
            }
            if (_characters.current == ']') {
              _depth--;
              if (_depth == 0) break;
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

Future<Digest> getArgon2Hash(
  String password, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
  int iterations = 2,
}) async {
  List<int> derivedPassword = (await argon2ifyString(
    password,
    salt: salt,
    parallelism: parallelism,
    memory: memory,
    iterations: iterations,
  ))
      .rawBytes;
  return sha512.convert(derivedPassword);
}

Future<Digest> getPasswordHash(
  String password, {
  required KeyDerivationType derivationType,
  KeyDerivationInfo? derivationInfo,
}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      return getPassyHash(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return await getArgon2Hash(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      );
  }
}

Future<Encrypter> getPasswordEncrypter(
  String password, {
  required KeyDerivationType derivationType,
  KeyDerivationInfo? derivationInfo,
}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      return getPassyEncrypter(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return getPassyEncrypterV2(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      );
  }
}

Future<String> getInternetAddress() async {
  try {
    String ip = '';
    List<NetworkInterface> _interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (NetworkInterface _interface in _interfaces) {
      for (InternetAddress _address in _interface.addresses) {
        String _strAddress = _address.address;
        if (_strAddress.startsWith('192.168.1.')) {
          ip = _strAddress;
          break;
        }
      }
    }
    if (ip == '') ip = (await intranetIpv4()).address;
    return ip;
  } catch (_) {
    return '127.0.0.1';
  }
}

List<String> _cliFiles = [
  'passy_cli' + (Platform.isWindows ? '.exe' : ''),
  'passy_cli_native_messaging' + (Platform.isWindows ? '.bat' : '.sh'),
  'passy_cli_native_messaging.json',
  Platform.isWindows
      ? 'argon2.dll'
      : (Platform.isLinux ? 'lib/libargon2.so' : ''),
];

Future<void> removePassyCLI(Directory directory) async {
  List<String> files = [
    ..._cliFiles,
    'autostart_add' + (Platform.isWindows ? '.bat' : '.sh'),
    'autostart_del' + (Platform.isWindows ? '.bat' : '.sh'),
  ];
  for (String fileName in files) {
    if (fileName.isEmpty) continue;
    File toFile = File(directory.path + Platform.pathSeparator + fileName);
    Directory toParent = toFile.parent;
    if (toParent.absolute.path == directory.absolute.path) {
      try {
        await toFile.delete();
      } catch (_) {}
      continue;
    }
    try {
      await toParent.delete(recursive: true);
    } catch (_) {}
  }
}

Future<File> copyPassyCLI(Directory from, Directory to) async {
  if (!await to.exists()) {
    await to.create(recursive: true);
  }
  for (String fileName in _cliFiles) {
    File fromFile = File(from.path + Platform.pathSeparator + fileName);
    File toFile = File(to.path + Platform.pathSeparator + fileName);
    if (await toFile.exists()) {
      try {
        await toFile.delete();
      } catch (_) {}
    } else if (!await toFile.parent.exists()) {
      try {
        await toFile.parent.create(recursive: true);
      } catch (_) {
        await removePassyCLI(to);
        rethrow;
      }
    }
    try {
      await fromFile.copy(toFile.path);
    } catch (_) {
      await removePassyCLI(to);
      rethrow;
    }
  }
  return File(to.path + Platform.pathSeparator + _cliFiles.first);
}

const String _passyServerAutorun = '''
hide
upgrade full "\$INSTALL_PATH"
sync host 2d0d0 \$SERVER_ADDRESS \$SERVER_PORT true
ipc server start true
''';

String _serverAutostartScriptLinux = '''
#!/bin/bash
cd \$(dirname \$0)
./passy_cli --no-autorun autostart add Passy-CLI-Server "\$PWD/passy_cli"
''';

String _serverAutostartScriptWindows = '''
SET "PASSY_PATH=%~dp0passy_cli.exe"
call "%%PASSY_PATH%%" --no-autorun autostart add Passy-CLI-Server "%%PASSY_PATH%%"
''';

Future<File> copyPassyCLIServer({
  required Directory from,
  required Directory to,
  required String address,
  int port = 5592,
}) async {
  File copy = await copyPassyCLI(from, to);
  File autorunFile =
      File(copy.parent.path + Platform.pathSeparator + 'autorun.pcli');
  try {
    await autorunFile.writeAsString(_passyServerAutorun
        .replaceFirst('\$INSTALL_PATH', from.path.replaceAll('\\', '\\\\'))
        .replaceFirst('\$SERVER_ADDRESS', address)
        .replaceFirst('\$SERVER_PORT', port.toString()));
  } catch (_) {
    await removePassyCLI(to);
    rethrow;
  }
  try {
    File autostartAdd = File(to.path +
        Platform.pathSeparator +
        'autostart_add' +
        (Platform.isWindows ? '.bat' : '.sh'));
    File autostartDel = File(to.path +
        Platform.pathSeparator +
        'autostart_del' +
        (Platform.isWindows ? '.bat' : '.sh'));
    if (await autostartAdd.exists()) {
      try {
        await autostartAdd.delete();
      } catch (_) {}
    }
    if (await autostartDel.exists()) {
      try {
        await autostartDel.delete();
      } catch (_) {}
    }
    try {
      String script = Platform.isWindows
          ? _serverAutostartScriptWindows
          : _serverAutostartScriptLinux;
      await autostartAdd.create();
      await autostartDel.create();
      await autostartAdd.writeAsString(script);
      await autostartDel.writeAsString(script.replaceFirst('add', 'del'));
      if (Platform.isLinux) {
        await setExecutionEnabled(autostartAdd.path, true);
        await setExecutionEnabled(autostartDel.path, true);
      }
    } catch (_) {
      await removePassyCLI(to);
      rethrow;
    }
  } catch (_) {
    await removePassyCLI(to);
    rethrow;
  }
  return copy;
}

Future<GlareClient> connectTo2d0d0Server(String address, int port,
    {RSAKeypair? keypair}) async {
  keypair ??= await compute<dynamic, RSAKeypair>(
      (message) => RSAKeypair.fromRandom(keySize: 2048), null);
  GlareClient? client;
  client = await GlareClient.connect(
    host: address,
    port: port,
    keypair: keypair,
  );
  return client;
}

Future<Digest> getFileChecksum(File file) async {
  AccumulatorSink<Digest> output = AccumulatorSink<Digest>();
  ByteConversionSink input = sha256.startChunkedConversion(output);
  await for (List<int> bytes in file.openRead()) {
    input.add(bytes);
  }
  input.close();
  return output.events.single;
}

String encodeCSVEntryForSaving({
  required List<dynamic> entry,
  required Encrypter encrypter,
}) {
  String key = entry[0];
  IV iv = IV.fromSecureRandom(16);
  return '$key,${iv.base64},${encrypt(csvEncode(entry), encrypter: encrypter, iv: iv)}\n';
}
