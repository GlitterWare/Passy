import 'package:passy/passy_data/csv_convertable.dart';

import 'json_convertable.dart';

enum EntryStatus { alive, removed }

EntryStatus? entryStatusFromText(String name) {
  switch (name) {
    case 'alive':
      return EntryStatus.alive;
    case 'removed':
      return EntryStatus.removed;
  }
  return null;
}

class EntryEvent with JsonConvertable, CSVConvertable {
  String key;
  EntryStatus status;
  DateTime lastModified;

  EntryEvent(
    this.key, {
    required this.status,
    required this.lastModified,
  });

  EntryEvent.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        status = entryStatusFromText(json['status']) ?? EntryStatus.removed,
        lastModified = DateTime.tryParse(json['lastModified']) ??
            DateTime.fromMillisecondsSinceEpoch(0);

  EntryEvent.fromCSV(List csv)
      : key = csv[0],
        status = entryStatusFromText(csv[1]) ?? EntryStatus.removed,
        lastModified =
            DateTime.tryParse(csv[2]) ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'status': status.name,
        'lastModified': lastModified.toIso8601String(),
      };

  @override
  List<List> toCSV() => [
        [
          key,
          status.name,
          lastModified.toIso8601String(),
        ]
      ];
}
