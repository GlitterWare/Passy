import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable(explicitToJson: true)
class Note {
  String title;
  String note;

  Note({
    required this.title,
    required this.note,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
