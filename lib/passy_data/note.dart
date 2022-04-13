import 'common.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef Notes = PassyEntries<Note>;

typedef NotesFile = PassyEntriesFile<Note>;

class Note extends PassyEntry<Note> {
  static const csvSchema = {
    'key': 1,
    'title': 2,
    'note': 3,
  };

  String title;
  String note;

  Note._({
    required String key,
    this.title = '',
    this.note = '',
  }) : super(key);

  Note({
    this.title = '',
    this.note = '',
  }) : super(DateTime.now().toUtc().toIso8601String());

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        note = json['note'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Note.fromCSV(List<List<dynamic>> csv,
      {Map<String, Map<String, int>> schemas = const {'note': csvSchema}})
      : title = csv[0][schemas['note']!['title']!],
        note = csv[0][schemas['note']!['note']!],
        super(csv[0][schemas['note']!['key']!]);

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
