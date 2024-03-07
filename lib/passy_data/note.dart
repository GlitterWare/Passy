import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/passy_kdbx_entry.dart';

import 'passy_entries.dart';
import 'passy_entries_encrypted_csv_file.dart';
import 'passy_entry.dart';

typedef Notes = PassyEntries<Note>;

typedef NotesFile = PassyEntriesEncryptedCSVFile<Note>;

class NoteMeta extends EntryMeta {
  final String title;

  NoteMeta({required String key, required this.title}) : super(key);

  @override
  toJson() => {
        'key': key,
        'title': title,
      };
}

class Note extends PassyEntry<Note> {
  String title;
  String note;
  bool isMarkdown;
  List<String> attachments;
  List<String> tags;

  Note({
    String? key,
    this.title = '',
    this.note = '',
    this.isMarkdown = false,
    List<String>? attachments,
    List<String>? tags,
  })  : attachments = attachments ?? [],
        tags = tags ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  EntryMeta get metadata => NoteMeta(key: key, title: title);

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        note = json['note'] ?? '',
        isMarkdown = json['isMarkdown'] ?? false,
        attachments = json['attachments'] == null
            ? []
            : (json['attachments'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
        tags = json['tags'] == null
            ? []
            : (json['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Note._fromCSV(List csv)
      : title = csv[1] ?? '',
        note = csv[2] ?? '',
        isMarkdown = boolFromString(csv[3] ?? 'false') ?? false,
        attachments =
            (csv[4] as List<dynamic>).map((e) => e.toString()).toList(),
        tags = (csv[5] as List<dynamic>).map((e) => e.toString()).toList(),
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  factory Note.fromCSV(List csv) {
    if (csv.length == 3) csv.add('false');
    if (csv.length == 4) csv.add([]);
    if (csv.length == 5) csv.add([]);
    return Note._fromCSV(csv);
  }

  @override
  int compareTo(Note other) => title.compareTo(other.title);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'note': note,
        'isMarkdown': isMarkdown,
        'tags': tags,
        'attachments': attachments,
      };

  @override
  List toCSV() => [
        key,
        title,
        note,
        isMarkdown.toString(),
        attachments,
      ];

  @override
  PassyKdbxEntry toKdbx() {
    return PassyKdbxEntry(
      title: title,
      customFields: [
        if (note.isNotEmpty) CustomField(title: 'Note', value: note),
      ],
    );
  }
}
