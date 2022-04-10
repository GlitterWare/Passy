import 'package:passy/passy_data/json_convertable.dart';

enum EntryStatus { alive, deleted }

const entryStatusToJson = {
  EntryStatus.alive: 'alive',
  EntryStatus.deleted: 'deleted',
};

const entryStatusFromJson = {
  'alive': EntryStatus.alive,
  'deleted': EntryStatus.deleted,
};

class EntryEvent implements JsonConvertable {
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.status,
    required this.lastModified,
  });

  factory EntryEvent.fromJson(Map<String, dynamic> json) => EntryEvent(
      status: entryStatusFromJson[json['status']] ?? EntryStatus.alive,
      lastModified: DateTime.parse(json['lastModified']));

  @override
  Map<String, dynamic> toJson() => {
        'status': entryStatusToJson[status],
        'lastModified': lastModified.toIso8601String(),
      };
}
