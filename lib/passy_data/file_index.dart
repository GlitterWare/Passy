import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/compression_type.dart';
import 'package:passy/passy_data/passy_binary_file.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:path/path.dart' as p;

import 'file_meta.dart';
import 'common.dart';

class FileIndex {
  final File _file;
  final Directory _saveDir;
  Key _key;
  Encrypter _encrypter;
  final List<String> _vPaths = [];

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

  void _loadIndex() {
    Map<String, PassyFsMeta> meta = metadataSync;
    for (PassyFsMeta entry in meta.values) {
      if (entry is! FileMeta) continue;
      _vPaths.add(entry.virtualPath);
    }
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
    _loadIndex();
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
    await tempRaf.lock();
    bool isEntrySet = false;
    void onEOF() {
      if (isEntrySet) return;
      if (entry == null) return;
      tempRaf.writeStringSync(_encodeEntryForSaving(entry));
      isEntrySet = true;
      _vPaths.add(entry.virtualPath);
    }

    await processLinesAsync(raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        onEOF();
        return true;
      }
      if (_key == key) {
        if (entry == null) {
          String? _entry = readLine(raf, lineDelimiter: '\n', onEOF: onEOF);
          if (_entry == null) {
            onEOF();
            return true;
          }
          List<String> decoded = _entry.split(',');
          String decrypted = decrypt(decoded[2],
              encrypter: _encrypter, iv: IV.fromBase64(decoded[0]));
          PassyFsMeta meta =
              PassyFsMeta.fromCSV(csvDecode(decrypted, recursive: true))!;
          _vPaths.remove(meta.virtualPath);
          isEntrySet = true;
          return null;
        }
        await raf.close();
        await tempRaf.unlock();
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
        await raf.close();
        await tempRaf.unlock();
        await tempRaf.close();
        await tempFile.delete();
        throw 'Matching file path found: duplicate paths not allowed.';
      }
      await tempRaf.writeString('$_key,$_entry\n');
      return null;
    });
    onEOF();
    await raf.close();
    await tempRaf.unlock();
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
      if (!(meta.virtualPath.startsWith(path))) {
        if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
        return null;
      }
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
    File file = File(_saveDir.path + Platform.pathSeparator + meta.key);
    if (await file.exists()) {
      throw Exception('File index error: index key exists.');
    }
    PassyBinaryFile binaryFile = PassyBinaryFile(file: file, key: _key);
    await binaryFile.encrypt(input: bytes, compressionType: compressionType);
    await _setEntry(meta.key, meta);
    return meta;
  }

  Future<FileMeta> addFile(
    File file, {
    FileMeta? meta,
    CompressionType compressionType = CompressionType.none,
    String? parent,
    bool eraseOriginalFile = false,
  }) async {
    meta ??= await FileMeta.fromFile(file, virtualParent: parent);
    FileMeta result = await addBytes(await file.readAsBytes(),
        meta: meta, compressionType: compressionType);
    if (eraseOriginalFile) {
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
    }
    return result;
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

  Future<List<PassyFsMeta>> removeFolder(String path) async {
    List<PassyFsMeta> result = [];
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
    await tempRaf.lock();

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
        result.add(meta);
        skipLine(raf, lineDelimiter: '\n');
        return null;
      }
      await tempRaf.writeString('$key,$entry\n');
      return null;
    });
    await raf.close();
    await tempRaf.unlock();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
    return result;
  }

  Future<void> _transformMeta(String key,
      {required PassyFsMeta Function(PassyFsMeta meta) transform}) async {
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
    await tempRaf.lock();

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
        try {
          meta = transform(meta);
        } catch (_) {
          await raf.close();
          await tempRaf.unlock();
          await tempRaf.close();
          await tempFile.delete();
          rethrow;
        }
        await tempRaf.writeString(_encodeEntryForSaving(meta));
        return null;
      }
      await tempRaf.writeString('$_key,$entry\n');
      return null;
    });
    await raf.close();
    await tempRaf.unlock();
    await tempRaf.close();
    await _file.delete();
    await tempFile.copy(_file.absolute.path);
    await tempFile.delete();
  }

  Future<void> renameFile(String key, {required String name}) async {
    return _transformMeta(key, transform: (meta) {
      List<String> vPathSplit = meta.virtualPath.split('/');
      vPathSplit.removeLast();
      vPathSplit.add(name);
      String newVPath = vPathSplit.join('/');
      if (_vPaths.contains(newVPath)) {
        throw 'Matching file path found: duplicate paths not allowed.';
      }
      PassyFsMeta result;
      if (meta is FileMeta) {
        result = FileMeta(
          key: meta.key,
          synchronized: meta.synchronized,
          tags: meta.tags,
          name: name,
          virtualPath: newVPath,
          path: meta.path,
          changed: meta.changed,
          modified: meta.modified,
          accessed: meta.accessed,
          size: meta.size,
          type: meta.type,
        );
      } else {
        throw 'Unknown FS metadata type: ${meta.runtimeType}';
      }
      _vPaths.remove(meta.virtualPath);
      _vPaths.add(newVPath);
      return result;
    });
  }

  Future<void> moveFile(String key, {required String path}) async {
    if (_vPaths.contains(path)) {
      throw 'Matching file path found: duplicate paths not allowed.';
    }
    return _transformMeta(key, transform: (meta) {
      PassyFsMeta result;
      if (meta is FileMeta) {
        result = FileMeta(
          key: meta.key,
          synchronized: meta.synchronized,
          tags: meta.tags,
          name: meta.name,
          virtualPath: path,
          path: meta.path,
          changed: meta.changed,
          modified: meta.modified,
          accessed: meta.accessed,
          size: meta.size,
          type: meta.type,
        );
      } else {
        throw 'Unknown FS metadata type: ${meta.runtimeType}';
      }
      _vPaths.remove(meta.virtualPath);
      _vPaths.add(path);
      return result;
    });
  }

  Future<void> changeFileType(String key, {required PassyFileType type}) async {
    return _transformMeta(key, transform: (meta) {
      if (meta is! FileMeta) return meta;
      meta.type = type;
      return meta;
    });
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
    await tempRaf.lock();
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
    await tempRaf.unlock();
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
    await _tempRaf.lock();
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
    await _tempRaf.unlock();
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
          List<String> vPath = meta.virtualPath.split('/');
          vPath = vPath.sublist(1, vPath.length);
          String filePath = p.join(path, vPath.join(Platform.pathSeparator));
          await binaryFile.export(File(filePath));
        }(),
    ]);
  }
}
