import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/compression_type.dart';
import 'package:passy/passy_data/passy_binary_file.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:path/path.dart' as p;

import 'file_meta.dart';
import 'common.dart';

class FileIndex {
  final File _file;
  final Directory _saveDir;
  Key _key;
  Encrypter _encrypter;

  List<String> get tags {
    List<String> _tags = [];
    RandomAccessFile _raf = _file.openSync();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      _raf.closeSync();
      return _tags;
    }
    const int _tagIndex = 2;
    processLines(_raf, onLine: (entry, eofReached) {
      List<String> _decoded = entry.split(',');
      String _decrypted = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      List<dynamic> _csv = csvDecode(_decrypted, recursive: true);
      if (_csv.length < _tagIndex + 1) {
        return true;
      }
      for (dynamic tag in (_csv[_tagIndex] as List<dynamic>)) {
        tag = tag.toString();
        if (_tags.contains(tag)) continue;
        _tags.add(tag);
      }
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    _raf.closeSync();
    return _tags;
  }

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

  String _encodeCSVForSaving(List<dynamic> csv) {
    IV _iv = IV.fromSecureRandom(16);
    return '${csv[0]},${_iv.base64},${sha256.convert(utf8.encode(csv[4])).toString()},${encrypt(csvEncode(csv), encrypter: _encrypter, iv: _iv)}\n';
  }

  String _encodeEntryForSaving(PassyFsMeta _entry) {
    return _encodeCSVForSaving(_entry.toCSV());
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

  Future<Map<String, PassyFsMeta>> getPathMetadata(String path) async {
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
      if (!(meta.virtualPath.startsWith(path))) return null;
      _meta[meta.key] = meta;
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    await _raf.close();
    return _meta;
  }

  Future<FileMeta> addBytes(
    Uint8List bytes, {
    required FileMeta meta,
    CompressionType compressionType = CompressionType.none,
  }) async {
    PassyBinaryFile binaryFile = PassyBinaryFile(
        file: File(_saveDir.path + Platform.pathSeparator + meta.key),
        key: _key);
    await binaryFile.encrypt(input: bytes, compressionType: compressionType);
    await _setEntry(meta.key, meta);
    return meta;
  }

  Future<FileMeta> addFile(
    File file, {
    FileMeta? meta,
    CompressionType compressionType = CompressionType.none,
    String? parent,
  }) async {
    meta ??= await FileMeta.fromFile(file, virtualParent: parent);
    return await addBytes(await file.readAsBytes(),
        meta: meta, compressionType: compressionType);
  }

  Future<Uint8List> readAsBytes(String key) {
    return PassyBinaryFile(
            file: File(_saveDir.path + Platform.pathSeparator + key), key: _key)
        .readAsBytes();
  }

  Future<void> saveDecrypted(String key, {required File file}) async {
    await file.writeAsBytes(await readAsBytes(key));
  }

  Future<void> removeFile(String key) async {
    File file = File(_saveDir.path + Platform.pathSeparator + key);
    if (await file.exists()) {
      FileStat stat = await file.stat();
      IOSink sink = file.openWrite(mode: FileMode.write);
      int curSize = 0;
      List<int> list =
          List<int>.filled(stat.size > 67108864 ? 67108864 : stat.size, 0);
      while (curSize < stat.size) {
        sink.add(list);
        curSize += 67108864;
      }
      await sink.flush();
      await file.delete();
    }
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

  Future<List<String>> renameTag({
    required String tag,
    required String newTag,
  }) async {
    List<String> keys = [];
    RandomAccessFile _raf = await _file.open();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      await _raf.close();
      return const [];
    }
    File _tempFile;
    {
      String _tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-entries-file-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      _tempFile = await File(_tempPath).create();
    }
    const int _tagIndex = 2;
    RandomAccessFile _tempRaf = await _tempFile.open(mode: FileMode.append);
    await processLinesAsync(_raf, onLine: (entry, eofReached) async {
      if (eofReached) return true;
      List<String> _decoded = entry.split(',');
      entry = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      List<dynamic> _csv = csvDecode(entry, recursive: true);
      if (_csv.length < _tagIndex + 1) {
        return true;
      }
      var tagList = _csv[_tagIndex];
      bool _changed = false;
      for (dynamic oldTag in (tagList as List<dynamic>).toList()) {
        oldTag = oldTag.toString();
        if (oldTag != tag) continue;
        _changed = true;
        tagList.remove(tag);
        tagList.add(newTag);
      }
      if (_changed) keys.add(_csv[0]);
      entry = _encodeCSVForSaving(_csv);
      await _tempRaf.writeString(entry);
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    await _raf.close();
    await _tempRaf.close();
    await _file.delete();
    await _tempFile.copy(_file.absolute.path);
    await _tempFile.delete();
    return keys;
  }

  Future<void> export(String path) async {
    Map<String, PassyFsMeta> metadata = await getMetadata();
    await Future.wait([
      for (PassyFsMeta meta in metadata.values)
        () async {
          PassyBinaryFile binaryFile = PassyBinaryFile(
              file: File(_saveDir.path + Platform.pathSeparator + meta.key),
              key: _key);
          List<String> vParent = meta.virtualPath.split('/');
          vParent = vParent.sublist(0, vParent.length - 1);
          String filePath = p.join(path, vParent.join(Platform.pathSeparator));
          await binaryFile.export(File(filePath));
        }(),
    ]);
  }
}
