import 'dated_entry.dart';

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
