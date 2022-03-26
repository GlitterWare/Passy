import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'note.dart';

class Notes {
  final List<Note> notes;
  final Encrypter _encrypter;
  final File _file;

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(notes), encrypter: _encrypter));
  void saveSync() => _file
      .writeAsStringSync(encrypt(jsonEncode(notes), encrypter: _encrypter));

  Notes._(
    File file, {
    required Encrypter encrypter,
    required this.notes,
  })  : _file = file,
        _encrypter = encrypter;

  factory Notes(File file, {required Encrypter encrypter}) {
    if (file.existsSync()) {
      List<dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return Notes._(
        file,
        encrypter: encrypter,
        notes:
            _json.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }
    file.createSync();
    Notes _notes = Notes._(
      file,
      encrypter: encrypter,
      notes: [],
    );
    _notes.saveSync();
    return _notes;
  }
}
