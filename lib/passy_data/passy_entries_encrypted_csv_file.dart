import 'package:encrypt/encrypt.dart';
import 'package:kdbx/kdbx.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'dart:io';

import 'passy_kdbx_value.dart';

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

  List<String> get tags {
    List<String> _tags = [];
    RandomAccessFile _raf = _file.openSync();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      _raf.closeSync();
      return _tags;
    }
    int _tagIndex = T.toString() == 'Note' ? 4 : 3;
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

  Map<String, EntryMeta> get metadata {
    Map<String, EntryMeta> _meta = {};
    RandomAccessFile _raf = _file.openSync();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      _raf.closeSync();
      return _meta;
    }
    processLines(_raf, onLine: (entry, eofReached) {
      List<String> _decoded = entry.split(',');
      String _decrypted = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      PassyEntry<T> _entry = PassyEntry.fromCSVString<T>(_decrypted) as T;
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
      String _decrypted = decrypt(_decoded1[2],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded1[1]));
      _entries[_decoded1[0]] = PassyEntry.fromCSVString<T>(_decrypted) as T;
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

  Future<void> setEncrypter(Encrypter encrypter,
      {Encrypter? oldEncrypter}) async {
    Encrypter oldEncrypterA = oldEncrypter ?? _encrypter;
    File _tempFile;
    {
      String _tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-entries-${entryTypeFromType(T)}-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      _tempFile = await File(_tempPath).create();
    }
    RandomAccessFile _raf = await _file.open();
    RandomAccessFile _tempRaf = await _tempFile.open(mode: FileMode.append);

    await processLinesAsync(_raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) return true;
      String? _entry = readLine(_raf, lineDelimiter: '\n');
      if (_entry == null) return true;
      List<String> _decoded = _entry.split(',');
      _entry = decrypt(_decoded[1],
          encrypter: oldEncrypterA, iv: IV.fromBase64(_decoded[0]));
      IV _iv = IV.fromSecureRandom(16);
      _entry = encrypt(_entry, encrypter: encrypter, iv: _iv);
      await _tempRaf.writeString('$_key,${_iv.base64},$_entry\n');
      return null;
    });
    await _raf.close();
    await _tempRaf.close();
    await _file.delete();
    await _tempFile.copy(_file.absolute.path);
    await _tempFile.delete();
    _encrypter = encrypter;
  }

  String _encodeEntryForSaving(List<dynamic> entry) =>
      encodeCSVEntryForSaving(entry: entry, encrypter: _encrypter);

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

  Map<String, String> getEntryStrings(List<String> keys) {
    Map<String, String> result = {};
    RandomAccessFile raf = _file.openSync();
    processLines(raf, lineDelimiter: ',', onLine: (key, eofReached) {
      if (eofReached) return true;
      if (keys.contains(key)) {
        String? entry = readLine(raf);
        if (entry == null) return true;
        List<String> decoded = entry.split(',');
        entry = decrypt(decoded[1],
            encrypter: _encrypter, iv: IV.fromBase64(decoded[0]));
        result[key] = entry;
        return null;
      }
      if (skipLine(raf) == -1) return true;
      return null;
    });
    raf.closeSync();
    return result;
  }

  List<dynamic>? getEntryCSV(String key) {
    String? _entryString = getEntryString(key);
    if (_entryString == null) return null;
    return PassyEntry.fromCSVString<T>(_entryString).toCSV();
  }

  Map<String, List<dynamic>> getEntryCSVs(List<String> keys) {
    Map<String, List<dynamic>> result = {};
    Map<String, String> entryStrings = getEntryStrings(keys);
    for (MapEntry<String, String> entryString in entryStrings.entries) {
      result[entryString.key] =
          PassyEntry.fromCSVString<T>(entryString.value).toCSV();
    }
    return result;
  }

  T? getEntry(String key) {
    List<dynamic>? _entryCSV = getEntryCSV(key);
    if (_entryCSV == null) return null;
    return PassyEntry.fromCSV(entryTypeFromType(T)!)(_entryCSV) as T;
  }

  Map<String, T> getEntries(List<String> keys) {
    Map<String, T> result = {};
    Map<String, List<dynamic>> entryCSVs = getEntryCSVs(keys);
    for (MapEntry<String, List<dynamic>> entryCSV in entryCSVs.entries) {
      T entry = PassyEntry.fromCSV(entryTypeFromType(T)!)(entryCSV.value) as T;
      result[entryCSV.key] = entry;
    }
    return result;
  }

  EntryMeta? getEntryMetadata(String key) {
    T? _entry = getEntry(key);
    if (_entry == null) return null;
    return _entry.metadata;
  }

  Map<String, EntryMeta> getEntriesMetadata(List<String> key) {
    Map<String, EntryMeta> result = {};
    Map<String, T> entries = getEntries(keys);
    for (MapEntry<String, T> entry in entries.entries) {
      result[entry.key] = entry.value.metadata;
    }
    return result;
  }

  Future<void> setEntry(String key, {T? entry}) async {
    File _tempFile;
    {
      String _tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-entries-${entryTypeFromType(T)}-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      _tempFile = await File(_tempPath).create();
    }
    RandomAccessFile _raf = await _file.open();
    RandomAccessFile _tempRaf = await _tempFile.open(mode: FileMode.append);
    bool _isEntrySet = false;
    void _onEOF() {
      if (_isEntrySet) return;
      if (entry == null) return;
      _tempRaf.writeStringSync(_encodeEntryForSaving(entry.toCSV()));
      _isEntrySet = true;
    }

    await processLinesAsync(_raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        _onEOF();
        return true;
      }
      if (_key == key) {
        skipLine(_raf, lineDelimiter: '\n', onEOF: _onEOF);
        _isEntrySet = true;
        if (entry == null) return null;
        await _tempRaf.writeString(_encodeEntryForSaving(entry.toCSV()));
        return null;
      }
      String? _entry = readLine(_raf, lineDelimiter: '\n', onEOF: _onEOF);
      if (_entry == null) {
        _onEOF();
        return true;
      }
      await _tempRaf.writeString('$_key,$_entry\n');
      return null;
    });
    _onEOF();
    await _raf.close();
    await _tempRaf.close();
    await _file.delete();
    await _tempFile.copy(_file.absolute.path);
    await _tempFile.delete();
  }

  Future<void> setEntries(Map<String, T?> entries) async {
    File _tempFile;
    {
      String _tempPath = (Directory.systemTemp).path +
          Platform.pathSeparator +
          'passy-set-entries-${entryTypeFromType(T)}-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      _tempFile = await File(_tempPath).create();
    }
    RandomAccessFile _raf = await _file.open();
    RandomAccessFile _tempRaf = await _tempFile.open(mode: FileMode.append);
    void _onEOF() {
      for (T? entry in entries.values) {
        if (entry == null) continue;
        _tempRaf.writeStringSync(_encodeEntryForSaving(entry.toCSV()));
      }
    }

    await processLinesAsync(_raf, lineDelimiter: ',',
        onLine: (_key, eofReached) async {
      if (eofReached) {
        _onEOF();
        return true;
      }
      if (entries.containsKey(_key)) {
        T? entry = entries[_key];
        entries.remove(_key);
        skipLine(_raf, lineDelimiter: '\n', onEOF: _onEOF);
        if (entry == null) return null;
        await _tempRaf.writeString(_encodeEntryForSaving(entry.toCSV()));
        return null;
      }
      String? _entry = readLine(_raf, lineDelimiter: '\n', onEOF: _onEOF);
      if (_entry == null) {
        _onEOF();
        return true;
      }
      await _tempRaf.writeString('$_key,$_entry\n');
      return null;
    });
    _onEOF();
    await _raf.close();
    await _tempRaf.close();
    await _file.delete();
    await _tempFile.copy(_file.absolute.path);
    await _tempFile.delete();
  }

  Future<void> export(File file,
      {String? annotation, bool skipKey = false}) async {
    if (!await file.exists()) await file.create(recursive: true);
    RandomAccessFile _raf = await _file.open();
    RandomAccessFile rafExport = await file.open(mode: FileMode.write);
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      await _raf.close();
      return;
    }
    if (annotation != null) {
      await rafExport.writeString(annotation + '\n');
    }
    processLines(_raf, onLine: (entry, eofReached) {
      if (eofReached) return true;
      List<String> _decoded = entry.split(',');
      String _decrypted = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      if (skipKey) _decrypted = _decrypted.split(',').sublist(1).join(',');
      rafExport
          .writeStringSync('"' + csvDecode(_decrypted).join('","') + '"\n');
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    await _raf.close();
    await rafExport.close();
  }

  Future<void> exportKdbx(KdbxFile file, {KdbxGroup? group}) async {
    final KdbxGroup groupFinal = group ?? file.body.rootGroup;
    RandomAccessFile _raf = await _file.open();
    if (skipLine(_raf, lineDelimiter: ',') == -1) {
      await _raf.close();
      return;
    }
    processLines(_raf, onLine: (entry, eofReached) {
      if (eofReached) return true;
      List<String> _decoded = entry.split(',');
      String _decrypted = decrypt(_decoded[1],
          encrypter: _encrypter, iv: IV.fromBase64(_decoded[0]));
      PassyEntry<T> passyEntry = PassyEntry.fromCSVString<T>(_decrypted) as T;
      final KdbxEntry kdbxEntry = KdbxEntry.create(file, groupFinal);
      for (PassyKdbxValue passyKdbxEntry in passyEntry.toKdbx().values) {
        kdbxEntry.setString(passyKdbxEntry.key, passyKdbxEntry.value);
      }
      groupFinal.addEntry(kdbxEntry);
      if (skipLine(_raf, lineDelimiter: ',') == -1) return true;
      return null;
    });
    await _raf.close();
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
          'passy-set-entries-${entryTypeFromType(T)}-' +
          DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
      _tempFile = await File(_tempPath).create();
    }
    int _tagIndex = T.toString() == 'Note' ? 4 : 3;
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
      entry = _encodeEntryForSaving(_csv);
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
}
