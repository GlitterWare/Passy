import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/compression_type.dart';
import 'package:passy/passy_data/passy_binary_file.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';

import 'file_meta.dart';
import 'common.dart';

class FileIndex {
  final File _file;
  final Directory _saveDir;
  Key _key;
  Encrypter _encrypter;

  FileIndex({
    required File file,
    required Directory saveDir,
    required Key key,
  })  : _file = file,
        _saveDir = saveDir,
        _key = key,
        _encrypter = Encrypter(AES(key)) {
    if (!_file.existsSync()) _file.createSync(recursive: true);
  }

  Map<String, PassyFsMeta> get metadataSync {
    Map<String, PassyFsMeta> _meta = {};
    RandomAccessFile _raf = _file.openSync();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      _raf.closeSync();
      return _meta;
    }
    processLines(_raf, onLine: (entry, eofReached) {
      List<String> decoded = entry.split(',');
      String decrypted = decrypt(decoded[2],
          encrypter: _encrypter, iv: IV.fromBase64(decoded[0]));
      PassyFsMeta meta =
          PassyFsMeta.fromCSV(csvDecode(decrypted, recursive: true))!;
      _meta[meta.key] = meta;
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    _raf.closeSync();
    return _meta;
  }

  Future<String?> getEntryString(String key) async {
    RandomAccessFile _raf = await _file.open();
    String? _entry;
    await processLinesAsync(_raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) return true;
      if (_key != key) {
        if (skipLine(_raf) == -1) return true;
        return null;
      }
      _entry = readLine(_raf);
      if (_entry == null) return true;
      List<String> _decoded = _entry!.split(',');
      _entry = decrypt(_decoded[2],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      return true;
    });
    await _raf.close();
    return _entry;
  }

  Future<Map<String, String>> getEntryStrings(List<String> keys) async {
    Map<String, String> result = {};
    RandomAccessFile raf = await _file.open();
    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (key, eofReached) async {
      if (eofReached) return true;
      if (keys.contains(key)) {
        String? entry = readLine(raf);
        if (entry == null) return true;
        List<String> decoded = entry.split(',');
        entry = decrypt(decoded[2],
            encrypter: _encrypter, iv: IV.fromBase64(decoded[0]));
        result[key] = entry;
        return null;
      }
      if (skipLine(raf) == -1) return true;
      return null;
    });
    await raf.close();
    return result;
  }

  Future<List<dynamic>?> getEntryCSV(String key) async {
    String? _entryString = await getEntryString(key);
    if (_entryString == null) return null;
    return csvDecode(_entryString, recursive: true);
  }

  Future<Map<String, List<dynamic>>> getEntryCSVs(List<String> keys) async {
    Map<String, List<dynamic>> result = {};
    Map<String, String> entryStrings = await getEntryStrings(keys);
    for (MapEntry<String, String> entryString in entryStrings.entries) {
      result[entryString.key] = csvDecode(entryString.value, recursive: true);
    }
    return result;
  }

  Future<PassyFsMeta?> getEntry(String key) async {
    List<dynamic>? _entryJson = await getEntryCSV(key);
    if (_entryJson == null) return null;
    return PassyFsMeta.fromCSV(_entryJson);
  }

  Future<Map<String, PassyFsMeta>> getEntries(List<String> keys) async {
    Map<String, PassyFsMeta> result = {};
    Map<String, List<dynamic>> entryCSVs = await getEntryCSVs(keys);
    for (MapEntry<String, List<dynamic>> entryCSV in entryCSVs.entries) {
      PassyFsMeta entry = PassyFsMeta.fromCSV(entryCSV.value) as PassyFsMeta;
      result[entryCSV.key] = entry;
    }
    return result;
  }

  String _encodeEntryForSaving(PassyFsMeta _entry) {
    IV _iv = IV.fromSecureRandom(16);
    return '${_entry.key},${_iv.base64},${sha256.convert(utf8.encode(_entry.virtualPath)).toString()},${encrypt(csvEncode(_entry.toCSV()), encrypter: _encrypter, iv: _iv)}\n';
  }

  Future<void> _setEntry(String key, PassyFsMeta? entry) async {
    String? fileHash = entry == null
        ? null
        : sha256.convert(utf8.encode(entry.virtualPath)).toString();
    File tempFile;
    {
      String tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-file-index-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      tempFile = await File(tempPath).create();
    }
    RandomAccessFile raf = await _file.open();
    RandomAccessFile tempRaf = await tempFile.open(mode: FileMode.append);
    bool isEntrySet = false;
    void onEOF() {
      if (isEntrySet) return;
      if (entry == null) return;
      tempRaf.writeStringSync(_encodeEntryForSaving(entry));
      isEntrySet = true;
    }

    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        onEOF();
        return true;
      }
      if (_key == key) {
        if (entry == null) {
          skipLine(raf, lineDelimiter: '\n', onEOF: onEOF);
          isEntrySet = true;
          return null;
        }
        await tempRaf.close();
        await tempFile.delete();
        throw 'Matching key found: duplicate files not allowed.';
      }
      String? _entry = readLine(raf, lineDelimiter: '\n', onEOF: onEOF);
      if (_entry == null) {
        onEOF();
        return true;
      }
      List<String> entrySplit = _entry.split(',');
      if (fileHash == entrySplit[1]) {
        await tempRaf.close();
        await tempFile.delete();
        throw 'Matching file path found: duplicate paths not allowed.';
      }
      await tempRaf.writeString('$_key,$_entry\n');
      return null;
    });
    onEOF();
    await raf.close();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
  }

  Future<Map<String, PassyFsMeta>> getMetadata() async {
    Map<String, PassyFsMeta> _meta = {};
    RandomAccessFile _raf = await _file.open();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      await _raf.close();
      return _meta;
    }
    await processLinesAsync(_raf, onLine: (entry, eofReached) async {
      List<String> decoded = entry.split(',');
      String decrypted = decrypt(decoded[2],
          encrypter: _encrypter, iv: IV.fromBase64(decoded[0]));
      PassyFsMeta meta =
          PassyFsMeta.fromCSV(csvDecode(decrypted, recursive: true))!;
      _meta[meta.key] = meta;
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    await _raf.close();
    return _meta;
  }

  Future<String> addFile(
    File file, {
    FileMeta? meta,
    CompressionType compressionType = CompressionType.none,
    String? parent,
  }) async {
    meta ??= await FileMeta.fromFile(file, virtualParent: parent);
    PassyBinaryFile binaryFile = PassyBinaryFile(
        file: File(_saveDir.path + Platform.pathSeparator + meta.key),
        key: _key);
    await binaryFile.encrypt(
        input: await file.readAsBytes(), compressionType: compressionType);
    await _setEntry(meta.key, meta);
    return meta.key;
  }

  Future<Uint8List> readAsBytes(String key) {
    return PassyBinaryFile(
            file: File(_saveDir.path + Platform.pathSeparator + key), key: _key)
        .readAsBytes();
  }

  Future<void> saveDecrypted(String key, {required File file}) async {
    await file.writeAsBytes(await PassyBinaryFile(
            file: File(_saveDir.path + Platform.pathSeparator + key), key: _key)
        .readAsBytes());
  }

  Future<void> removeFile(String key) async {
    File file = File(_saveDir.path + Platform.pathSeparator + key);
    if (await file.exists()) await file.delete();
    await _setEntry(key, null);
  }

  Future<void> removeFolder(String path) async {
    if (path.isNotEmpty) {
      if (path[path.length - 1] != '/') path = path + '/';
    } else {
      path = '/';
    }
    File tempFile;
    {
      String tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-file-index-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      tempFile = await File(tempPath).create();
    }
    RandomAccessFile raf = await _file.open();
    RandomAccessFile tempRaf = await tempFile.open(mode: FileMode.append);

    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (key, eofReached) async {
      if (eofReached) return true;
      String? entry = readLine(raf, lineDelimiter: '\n');
      if (entry == null) return true;
      List<String> entrySplit = entry.split(',');
      IV iv = IV.fromBase64(entrySplit[0]);
      PassyFsMeta meta = PassyFsMeta.fromCSV(csvDecode(
          decrypt(entrySplit[2], encrypter: _encrypter, iv: iv),
          recursive: true))!;
      if (meta.virtualPath.startsWith(path)) {
        skipLine(raf, lineDelimiter: '\n');
        return null;
      }
      await tempRaf.writeString('$key,$entry\n');
      return null;
    });
    await raf.close();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
  }

  Future<void> renameFile(String key, {required String name}) async {
    File tempFile;
    {
      String tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-file-index-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      tempFile = await File(tempPath).create();
    }
    RandomAccessFile raf = await _file.open();
    RandomAccessFile tempRaf = await tempFile.open(mode: FileMode.append);

    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) return true;
      String? entry = readLine(raf, lineDelimiter: '\n');
      if (entry == null) return true;
      List<String> entrySplit = entry.split(',');
      if (_key == key) {
        PassyFsMeta? meta = PassyFsMeta.fromCSV(csvDecode(
            decrypt(entrySplit[2],
                encrypter: _encrypter, iv: IV.fromBase64(entrySplit[0])),
            recursive: true));
        if (meta == null) return true;
        meta.name = name;
        await tempRaf.writeString(_encodeEntryForSaving(meta));
        return null;
      }
      await tempRaf.writeString('$_key,$entry\n');
      return null;
    });
    await raf.close();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
  }

  Future<void> setKey(Key key, {Encrypter? oldEncrypter}) async {
    Encrypter encrypter = Encrypter(AES(key));
    Encrypter oldEncrypterA = oldEncrypter ?? _encrypter;
    File tempFile;
    {
      String tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-file-index-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      tempFile = await File(tempPath).create();
    }
    RandomAccessFile raf = await _file.open();
    RandomAccessFile tempRaf = await tempFile.open(mode: FileMode.append);
    List<String> keys = [];

    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      keys.add(_key);
      if (eofReached) return true;
      String? entry = readLine(raf, lineDelimiter: '\n');
      if (entry == null) return true;
      List<String> decoded = entry.split(',');
      entry = decrypt(decoded[2],
          encrypter: oldEncrypterA, iv: IV.fromBase64(decoded[0]));
      IV iv = IV.fromSecureRandom(16);
      entry = encrypt(entry, encrypter: encrypter, iv: iv);
      await tempRaf.writeString('$_key,${iv.base64},${decoded[1]},$entry\n');
      return null;
    });
    await raf.close();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
    Key _oldKey = _key;
    _key = key;
    _encrypter = encrypter;
    for (String fileKey in keys) {
      File file = File(_saveDir.path + Platform.pathSeparator + fileKey);
      PassyBinaryFile oldFile = PassyBinaryFile(file: file, key: _oldKey);
      PassyBinaryFile newFile = PassyBinaryFile(file: file, key: key);
      newFile.encrypt(input: await oldFile.readAsBytes());
    }
  }
}
