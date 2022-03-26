import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'identity.dart';

class Identities {
  final List<Identity> identities;
  final Encrypter _encrypter;
  final File _file;

  Future<void> save() => _file
      .writeAsString(encrypt(jsonEncode(identities), encrypter: _encrypter));
  void saveSync() => _file.writeAsStringSync(
      encrypt(jsonEncode(identities), encrypter: _encrypter));

  Identities._(
    File file, {
    required Encrypter encrypter,
    required this.identities,
  })  : _file = file,
        _encrypter = encrypter;

  factory Identities(File file, {required Encrypter encrypter}) {
    if (file.existsSync()) {
      List<dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return Identities._(
        file,
        encrypter: encrypter,
        identities: _json
            .map((e) => Identity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    file.createSync();
    Identities _identities = Identities._(
      file,
      encrypter: encrypter,
      identities: [],
    );
    _identities.saveSync();
    return _identities;
  }
}
