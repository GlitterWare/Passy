import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

typedef Notes = DatedEntries<Note>;

class NotesFile extends EncryptedJsonFile<Notes> {
  NotesFile._(File file, Encrypter encrypter, {required Notes value})
      : super(file, encrypter, value: value);

  factory NotesFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return NotesFile._(file, encrypter,
          value: Notes.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    file.createSync(recursive: true);
    NotesFile _file = NotesFile._(file, encrypter, value: Notes());
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
        title: json['title'] ?? '',
        note: json['note'] ?? '',
        creationDate:
            json['creationDate'] ?? DateTime.now().toUtc().toIso8601String(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'note': note,
        'creationDate': creationDate,
      };

  Note._({
    required this.title,
    required this.note,
    required String creationDate,
  }) : super(creationDate);

  Note({
    required this.title,
    required this.note,
  }) : super(DateTime.now().toUtc().toIso8601String());
}
