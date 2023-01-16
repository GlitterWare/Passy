import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PassyEntriesEncryptedCSVFile<T extends PassyEntry<T>> {
  final File _file;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  List<String> get keys {
    List<String> _keys = [];
    RandomAccessFile _raf = _file.openSync();
    processLines(_raf, lineDelimiter: ',', onLine: (key, eofReached) {
      _keys.add(key);
      skipLine(_raf, lineDelimiter: '\n');
      return null;
    });
    _raf.closeSync();
    return _keys;
  }

  Map<String, EntryMeta> get metadata {
    Map<String, EntryMeta> _meta = {};
    RandomAccessFile _raf = _file.openSync();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      _raf.closeSync();
      return _meta;
    }
    processLines(_raf, onLine: (entry, eofReached) {
      List<String> _decoded = entry.split(',');
      PassyEntry<T> _entry = PassyEntry.fromCSV(entryTypeFromType(T))(csvDecode(
          decrypt(_decoded[1],
              encrypter: _encrypter, iv: IV.fromBase64(_decoded[0])),
          recursive: true)) as T;
      _meta[_entry.key] = _entry.metadata;
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    _raf.closeSync();
    return _meta;
  }

  Map<String, T> get entries {
    Map<String, T> _entries = {};
    RandomAccessFile _raf = _file.openSync();
    processLines(_raf, onLine: (line, eofReached) {
      List<String> _decoded1 = line.split(',');
      List<dynamic> _decoded2 = csvDecode(
          decrypt(_decoded1[2],
              encrypter: _encrypter, iv: IV.fromBase64(_decoded1[1])),
          recursive: true);
      _entries[_decoded1[0]] =
          (PassyEntry.fromCSV(entryTypeFromType(T)!)(_decoded2) as T);
      return null;
    });
    _raf.closeSync();
    return _entries;
  }

  PassyEntriesEncryptedCSVFile(
    this._file, {
    required Encrypter encrypter,
  }) : _encrypter = encrypter;

  factory PassyEntriesEncryptedCSVFile.fromFile(
    File file, {
    required Encrypter encrypter,
  }) {
    file.createSync(recursive: true);
    return PassyEntriesEncryptedCSVFile<T>(
      file,
      encrypter: encrypter,
    );
  }

  String _encodeEntryForSaving(List<dynamic> _entry) {
    String _key = _entry[0];
    IV _iv = IV.fromSecureRandom(16);
    return '$_key,${_iv.base64},${encrypt(csvEncode(_entry), encrypter: _encrypter, iv: _iv)}\n';
  }

  String? getEntryString(String key) {
    RandomAccessFile _raf = _file.openSync();
    String? _entry;
    processLines(_raf, lineDelimiter: ',', onLine: (_key, eofReached) {
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
    _raf.closeSync();
    return _entry;
  }

  List<dynamic>? getEntryCSV(String key) {
    String? _entryString = getEntryString(key);
    if (_entryString == null) return null;
    return csvDecode(_entryString, recursive: true);
  }

  T? getEntry(String key) {
    List<dynamic>? _entryCSV = getEntryCSV(key);
    if (_entryCSV == null) return null;
    return PassyEntry.fromCSV(entryTypeFromType(T)!)(_entryCSV) as T;
  }

  EntryMeta? getEntryMetadata(String key) {
    T? _entry = getEntry(key);
    if (_entry == null) return null;
    return _entry.metadata;
  }

  Future<void> setEntry(String key, {T? entry}) async {
    File _tempFile;
    {
      String _tempPath = (await getTemporaryDirectory()).path +
          Platform.pathSeparator +
          'passy-set-entries-${entryTypeFromType(T)}-' +
          DateTime.now().toIso8601String().replaceAll(':', ';');
      _tempFile = await _file.copy(_tempPath);
    }
    await _file.writeAsString('');
    RandomAccessFile _raf = await _file.open(mode: FileMode.append);
    RandomAccessFile _tempRaf = await _tempFile.open();
    bool _isEntrySet = false;
    void _onEOF() {
      if (_isEntrySet) return;
      if (entry == null) return;
      _raf.writeStringSync(_encodeEntryForSaving(entry.toCSV()));
      _isEntrySet = true;
    }

    await processLinesAsync(_tempRaf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        _onEOF();
        return true;
      }
      if (_key == key) {
        skipLine(_tempRaf, lineDelimiter: '\n', onEOF: _onEOF);
        _isEntrySet = true;
        if (entry == null) return null;
        await _raf.writeString(_encodeEntryForSaving(entry.toCSV()));
        return null;
      }
      String? _entry = readLine(_tempRaf, lineDelimiter: '\n', onEOF: _onEOF);
      if (_entry == null) {
        _onEOF();
        return true;
      }
      await _raf.writeString('$_key,$_entry\n');
      return null;
    });
    _onEOF();
    await _raf.close();
    await _tempRaf.close();
    await _tempFile.delete();
  }
}
