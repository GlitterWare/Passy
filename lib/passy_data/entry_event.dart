import 'package:passy/passy_data/json_convertable.dart';

enum EntryStatus { alive, deleted, error }

EntryStatus entryStatusFromText(String name) {
  switch (name) {
    case 'alive':
      return EntryStatus.alive;
    case 'deleted':
      return EntryStatus.deleted;
    default:
      return EntryStatus.error;
  }
}

class EntryEvent implements JsonConvertable {
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.status,
    required this.lastModified,
  });

  factory EntryEvent.fromJson(Map<String, dynamic> json) => EntryEvent(
      status: entryStatusFromText(json['status'] ?? 'deleted'),
      lastModified: DateTime.parse(json['lastModified']));

  @override
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'lastModified': lastModified.toIso8601String(),
      };
}
