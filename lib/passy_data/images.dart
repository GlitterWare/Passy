import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'passy_bytes.dart';
import 'passy_entries.dart';

class PassyImages extends PassyEntries<PassyBytes> {
  final Map<String, String> _indexes;
  final List<String> _freeIndexes;

  final String _path;
  final File _file;

  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  PassyImages._(
    this._path, {
    required Encrypter encrypter,
    required Map<String, PassyBytes> entries,
    required Map<String, String> indexes,
    required List<String> freeIndexes,
    required File file,
  })  : _encrypter = encrypter,
        _indexes = indexes,
        _freeIndexes = freeIndexes,
        _file = file,
        super(entries: entries);

  factory PassyImages(String path, {required Encrypter encrypter}) {
    File _file = File(path + Platform.pathSeparator + 'images.json');
    if (_file.existsSync()) {
      Map<String, dynamic> _json =
          jsonDecode(decrypt(_file.readAsStringSync(), encrypter: encrypter));
      Map<String, String> _imageIndexes =
          (_json['imageIndexes'] as Map<String, dynamic>?)?.map((key, value) =>
                  MapEntry(decrypt(key, encrypter: encrypter), value)) ??
              {};
      return PassyImages._(path,
          encrypter: encrypter,
          entries: _imageIndexes.map((key, value) => MapEntry(
              key,
              PassyBytes(key,
                  value: base64Decode(decrypt(
                      File(path + Platform.pathSeparator + value.toString())
                          .readAsStringSync(),
                      encrypter: encrypter))))),
          indexes: _imageIndexes,
          freeIndexes: (_json['freeIndexes'] as List<dynamic>).cast<String>(),
          file: _file);
    }
    _file.createSync(recursive: true);
    PassyImages _images = PassyImages._(path,
        encrypter: encrypter,
        entries: {},
        indexes: {},
        freeIndexes: [],
        file: _file);
    _images.saveSync();
    return _images;
  }

  @override
  Map<String, dynamic> toJson() => {
        'imageIndexes': _indexes.map((key, value) =>
            MapEntry(encrypt(key, encrypter: _encrypter), value)),
        'freeImageIndexes': _freeIndexes,
      };

  @override
  void setEntry(PassyBytes entry) {
    super.setEntry(entry);

    if (!_indexes.containsKey(entry.key)) {
      if (_freeIndexes.isEmpty) {
        _indexes[entry.key] = _indexes.length.toRadixString(36);
      } else {
        _indexes[entry.key] = _freeIndexes.last;
        _freeIndexes.removeAt(_freeIndexes.length - 1);
      }
    }

    File(_path +
        Platform.pathSeparator +
        _indexes[entry.key].toString() +
        '.enc')
      ..createSync()
      ..writeAsStringSync(
          encrypt(base64Encode(entry.value), encrypter: _encrypter));
  }

  @override
  void removeEntry(String key) {
    super.removeEntry(key);
    File(_path + Platform.pathSeparator + _indexes[key].toString() + '.enc')
        .deleteSync();
    _indexes.remove(key);
  }

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(this), encrypter: _encrypter));

  void saveSync() =>
      _file.writeAsStringSync(encrypt(jsonEncode(this), encrypter: _encrypter));
}
