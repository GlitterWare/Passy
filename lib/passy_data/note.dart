import 'package:passy/passy_data/passy_entries_file.dart';

import 'common.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef Notes = PassyEntries<Note>;

typedef NotesFile = PassyEntriesFile<Note>;

class Note extends PassyEntry<Note> {
  String title;
  String note;

  Note({
    this.title = '',
    this.note = '',
  }) : super(DateTime.now().toUtc().toIso8601String());

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        note = json['note'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  factory Note.fromCSV(List<List<dynamic>> csv,
      {Map<String, Map<String, int>> templates = const {}}) {
    // TODO: implement fromCSV
    throw UnimplementedError();
  }

  @override
  int compareTo(Note other) => title.compareTo(other.title);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'note': note,
      };

  @override
  List<List> toCSV() => jsonToCSV('note', toJson());
}
