import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PassyEntriesEncryptedCSVFile<T extends PassyEntry<T>> {
  final File _file;
  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  Map<String, T> get entries {
    Map<String, T> _entries = {};
    RandomAccessFile _raf = _file.openSync();
    bool eofReached = false;
    do {
      String? line = readLine(_raf, onEOF: () => eofReached = true);
      if (line == null) continue;
      List<dynamic> _decoded1 = csvDecode(line);
      List<dynamic> _decoded2 = csvDecode(
          decrypt(_decoded1[1], encrypter: _encrypter),
          recursive: true);
      _entries[_decoded1[0]] =
          (PassyEntry.fromCSV(entryTypeFromType(T)!)(_decoded2) as T);
    } while (eofReached == false);
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
    return '$_key,${encrypt(csvEncode(_entry), encrypter: _encrypter)}\n';
  }

  T? getEntry(String key) {
    RandomAccessFile _raf = _file.openSync();
    bool _eofReached = false;
    void _onEOF() => _eofReached = true;
    do {
      String? _key = readLine(_raf, lineDelimiter: ',', onEOF: _onEOF);
      if (_key == null) continue;
      if (_key == key) {
        if (_eofReached) return null;
        String? _entry = readLine(_raf, onEOF: _onEOF);
        if (_entry == null) return null;
        return PassyEntry.fromCSV(entryTypeFromType(T)!)(csvDecode(
            decrypt(_entry, encrypter: _encrypter),
            recursive: true)) as T;
      }
      skipLine(_raf, onEOF: _onEOF);
    } while (_eofReached == false);
    _raf.closeSync();
    return null;
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
    bool _eofReached = false;
    void _onEOF() {
      _eofReached = true;
      if (_isEntrySet) return;
      if (entry == null) return;
      _raf.writeStringSync(_encodeEntryForSaving(entry.toCSV()));
    }

    do {
      String? _key = readLine(_tempRaf, lineDelimiter: ',', onEOF: _onEOF);
      if (_key == null) continue;
      String? _entry = readLine(_tempRaf, lineDelimiter: '\n', onEOF: _onEOF);
      if (_key == key) {
        if (entry == null) continue;
        if (_eofReached) return;
        _isEntrySet = true;
        await _raf.writeString(_encodeEntryForSaving(entry.toCSV()));
        continue;
      }
      if (_entry == null) continue;
      await _raf.writeString('$_key,$_entry\n');
    } while (_eofReached == false);
    await _raf.close();
    await _tempRaf.close();
    await _tempFile.delete();
  }
}
