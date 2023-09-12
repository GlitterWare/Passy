import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/passy_binary_file.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';

import 'file_meta.dart';
import 'common.dart';

class FileIndex {
  final File _file;
  final Directory _saveDir;
  final Key _key;
  final Encrypter _encrypter;

  FileIndex({
    required File file,
    required Directory saveDir,
    required Key key,
    required Encrypter encrypter,
  })  : _file = file,
        _saveDir = saveDir,
        _key = key,
        _encrypter = encrypter {
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
      String decrypted = decrypt(decoded[1],
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
      _entry = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      return true;
    });
    await _raf.close();
    return _entry;
  }

  Future<List<dynamic>?> getEntryCSV(String key) async {
    String? _entryString = await getEntryString(key);
    if (_entryString == null) return null;
    return csvDecode(_entryString, recursive: true);
  }

  Future<PassyFsMeta?> getEntry(String key) async {
    List<dynamic>? _entryJson = await getEntryCSV(key);
    if (_entryJson == null) return null;
    return PassyFsMeta.fromCSV(_entryJson);
  }

  String _encodeEntryForSaving(PassyFsMeta _entry) {
    IV _iv = IV.fromSecureRandom(16);
    return '${_entry.key},${_iv.base64},${encrypt(csvEncode(_entry.toCSV()), encrypter: _encrypter, iv: _iv)}\n';
  }

  Future<void> _setEntry(String key, PassyFsMeta? entry) async {
    File tempFile;
    {
      String tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-file-index-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      tempFile = await _file.copy(tempPath);
    }
    await _file.writeAsString('');
    RandomAccessFile raf = await _file.open(mode: FileMode.append);
    RandomAccessFile tempRaf = await tempFile.open();
    bool isEntrySet = false;
    void onEOF() {
      if (isEntrySet) return;
      if (entry == null) return;
      raf.writeStringSync(_encodeEntryForSaving(entry));
      isEntrySet = true;
    }

    await processLinesAsync(tempRaf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        onEOF();
        return true;
      }
      if (_key == key) {
        skipLine(tempRaf, lineDelimiter: '\n', onEOF: onEOF);
        isEntrySet = true;
        if (entry == null) return null;
        await raf.writeString(_encodeEntryForSaving(entry));
        return null;
      }
      String? _entry = readLine(tempRaf, lineDelimiter: '\n', onEOF: onEOF);
      if (_entry == null) {
        onEOF();
        return true;
      }
      await raf.writeString('$_key,$_entry\n');
      return null;
    });
    onEOF();
    await raf.close();
    await tempRaf.close();
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
      String decrypted = decrypt(decoded[1],
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
    String parent = '/',
  }) async {
    meta ??= FileMeta.fromFile(file);
    PassyBinaryFile.fromDecryptedSync(
        input: file,
        output: File(_saveDir.path + Platform.pathSeparator + meta.key),
        key: _key);
    await _setEntry(meta.key, meta);
    return meta.key;
  }

  Future<Uint8List> readAsBytes(String key) {
    return PassyBinaryFile(
            file: File(_saveDir.path + Platform.pathSeparator + key), key: _key)
        .readAsBytes();
  }

  Future<void> saveDecrypted(String key, {required File file}) {
    return PassyBinaryFile(
            file: File(_saveDir.path + Platform.pathSeparator + key), key: _key)
        .saveDecrypted(file);
  }

  Future<void> removeFile(String key) async {
    await File(_saveDir.path + Platform.pathSeparator + key).delete();
    await _setEntry(key, null);
  }
}
