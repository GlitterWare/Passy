import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'encrypted_json_file.dart';

typedef Notes = PassyEntries<Note>;

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

class Note extends PassyEntry<Note> {
  String title;
  String note;

  Note({
    required this.title,
    required this.note,
  }) : super(DateTime.now().toUtc().toIso8601String());

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        note = json['note'] ?? '',
        super(json['creationDate'] ?? DateTime.now().toUtc().toIso8601String());

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'note': note,
        'creationDate': key,
      };

  @override
  int compareTo(Note other) => title.compareTo(other.title);
}
