import 'package:passy/passy_data/csv_convertable.dart';

import 'json_convertable.dart';

enum EntryStatus { alive, deleted }

EntryStatus? entryStatusFromText(String name) {
  switch (name) {
    case 'alive':
      return EntryStatus.alive;
    case 'deleted':
      return EntryStatus.deleted;
  }
  return null;
}

class EntryEvent with JsonConvertable, CSVConvertable {
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.status,
    required this.lastModified,
  });

  EntryEvent.fromJson(Map<String, dynamic> json)
      : status = entryStatusFromText(json['status']) ?? EntryStatus.deleted,
        lastModified = DateTime.tryParse(json['lastModified']) ??
            DateTime.fromMillisecondsSinceEpoch(0);

  EntryEvent.fromCSV(List csv)
      : status = entryStatusFromText(csv[0]) ?? EntryStatus.deleted,
        lastModified =
            DateTime.tryParse(csv[1]) ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'lastModified': lastModified.toIso8601String(),
      };

  @override
  List toCSV() => [
        status.name,
        lastModified.toIso8601String(),
      ];
}
