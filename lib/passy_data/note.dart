import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

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

class Note extends DatedEntry<Note> {
  String title;
  String note;

  @override
  int compareTo(Note other) => title.compareTo(other.title);

  factory Note.fromJson(Map<String, dynamic> json) => Note._(
        title: json['title'] as String,
        note: json['note'] as String,
        creationDate:
            DateTime.tryParse(json['creationDate']) ?? DateTime.now().toUtc(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'note': note,
        'creationDate': creationDate.toIso8601String(),
      };

  Note._({
    required this.title,
    required this.note,
    required DateTime creationDate,
  }) : super(creationDate);

  Note({
    required this.title,
    required this.note,
  }) : super(DateTime.now().toUtc());
}
