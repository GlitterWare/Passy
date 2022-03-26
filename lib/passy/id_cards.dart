import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'id_card.dart';

class IDCards {
  final List<IDCard> notes;
  final Encrypter _encrypter;
  final File _file;

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(notes), encrypter: _encrypter));
  void saveSync() => _file
      .writeAsStringSync(encrypt(jsonEncode(notes), encrypter: _encrypter));

  IDCards._(
    File file, {
    required Encrypter encrypter,
    required this.notes,
  })  : _file = file,
        _encrypter = encrypter;

  factory IDCards(File file, {required Encrypter encrypter}) {
    if (file.existsSync()) {
      List<dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return IDCards._(
        file,
        encrypter: encrypter,
        notes: _json
            .map((e) => IDCard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    file.createSync();
    IDCards _idCards = IDCards._(
      file,
      encrypter: encrypter,
      notes: [],
    );
    _idCards.saveSync();
    return _idCards;
  }
}
