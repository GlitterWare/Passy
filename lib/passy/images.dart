import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/common.dart';
import 'package:universal_io/io.dart';

class Images {
  final Map<String, Uint8List> _images;

  final Map<String, String> _imageIndexes;
  final List<String> _freeimageIndexes;

  final String _path;
  final File _file;

  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  Uint8List? getImage(String name) => _images[name];

  void _setImage(String name, Uint8List image) {
    if (!_images.containsKey(name)) {
      if (_freeimageIndexes.isEmpty) {
        _imageIndexes[name] = _images.length.toRadixString(36);
      } else {
        _imageIndexes[name] = _freeimageIndexes.last;
        _freeimageIndexes.removeAt(_freeimageIndexes.length - 1);
      }
    }
    _images[name] = image;
  }

  Future<void> setImage(String name, Uint8List image) async {
    _setImage(name, image);
    File _file = File(_path +
        Platform.pathSeparator +
        _imageIndexes[name].toString() +
        '.enc');
    await _file.create();
    await _file
        .writeAsString(encrypt(base64Encode(image), encrypter: _encrypter));
  }

  void setImageSync(String name, Uint8List icon) {
    _setImage(name, icon);
    File _file = File(_path +
        Platform.pathSeparator +
        _imageIndexes[name].toString() +
        '.enc');
    _file.createSync();
    _file.writeAsStringSync(encrypt(base64Encode(icon), encrypter: _encrypter));
  }

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(this), encrypter: _encrypter));

  void saveSync() =>
      _file.writeAsStringSync(encrypt(jsonEncode(this), encrypter: _encrypter));

  Images._(
    this._path, {
    required Encrypter encrypter,
    required Map<String, Uint8List> images,
    required Map<String, String> imageIndexes,
    required List<String> freeImageIndexes,
    required File file,
  })  : _encrypter = encrypter,
        _images = images,
        _imageIndexes = imageIndexes,
        _freeimageIndexes = freeImageIndexes,
        _file = file;

  factory Images(String path, {required Encrypter encrypter}) {
    File _file = File(path + Platform.pathSeparator + 'images.json');
    if (_file.existsSync()) {
      Map<String, dynamic> _json =
          jsonDecode(decrypt(_file.readAsStringSync(), encrypter: encrypter));
      Map<String, String> _imageIndexes =
          (_json['imageIndexes'] as Map<String, dynamic>).map((key, value) =>
              MapEntry(decrypt(key, encrypter: encrypter), value));
      return Images._(path,
          encrypter: encrypter,
          images: _imageIndexes.map((key, value) => MapEntry(
              key,
              base64Decode(decrypt(
                  File(path + Platform.pathSeparator + value.toString())
                      .readAsStringSync(),
                  encrypter: encrypter)))),
          imageIndexes: _imageIndexes,
          freeImageIndexes:
              (_json['freeImageIndexes'] as List<dynamic>).cast<String>(),
          file: _file);
    }
    _file.createSync(recursive: true);
    Images _images = Images._(path,
        encrypter: encrypter,
        images: {},
        imageIndexes: {},
        freeImageIndexes: [],
        file: _file);
    _images.saveSync();
    return _images;
  }

  Map<String, dynamic> toJson() => {
        'imageIndexes': _imageIndexes.map((key, value) =>
            MapEntry(encrypt(key, encrypter: _encrypter), value)),
        'freeImageIndexes': _freeimageIndexes,
      };
}
