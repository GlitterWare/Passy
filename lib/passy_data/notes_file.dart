import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'encrypted_json_file.dart';
import 'note.dart';

class NotesFile extends EncryptedJsonFile<DatedEntries<Note>> {
  NotesFile._(File file, Encrypter encrypter,
      {required DatedEntries<Note> value})
      : super(file, encrypter, value: value);

  factory NotesFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return NotesFile._(file, encrypter,
          value: DatedEntries<Note>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    NotesFile _file = NotesFile._(file, encrypter, value: DatedEntries<Note>());
    _file.saveSync();
    return _file;
  }
}
