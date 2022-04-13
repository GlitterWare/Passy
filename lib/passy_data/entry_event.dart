import 'json_convertable.dart';

enum EntryStatus { alive, deleted }

EntryStatus entryStatusFromText(String name) {
  switch (name) {
    case 'alive':
      return EntryStatus.alive;
    case 'deleted':
      return EntryStatus.deleted;
    default:
      throw Exception('Cannot convert String \'$name\' to EntryStatus');
  }
}

class EntryEvent implements JsonConvertable {
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.status,
    required this.lastModified,
  });

  EntryEvent.fromJson(Map<String, dynamic> json)
      : status = entryStatusFromText(json['status'] ?? 'deleted'),
        lastModified = DateTime.parse(json['lastModified']);

  @override
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'lastModified': lastModified.toIso8601String(),
      };
}
