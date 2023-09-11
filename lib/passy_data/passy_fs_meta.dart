import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/file_meta.dart';

import 'entry_event.dart';

class PassyFsMeta with CSVConvertable {
  final String key;
  final String name;
  EntryStatus status;
  DateTime entryModified;

  PassyFsMeta({
    String? key,
    required this.name,
    required this.status,
    DateTime? entryModified,
  })  : key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c'),
        entryModified = entryModified ?? DateTime.now().toUtc();

  static PassyFsMeta? fromCSV(List<dynamic> csv) {
    if (csv.length == 4) {
      return PassyFsMeta(
        key: csv[0],
        name: csv[1],
        status: entryStatusFromText(csv[2])!,
        entryModified: DateTime.parse(csv[3]),
      );
    }
    switch (csv[4]) {
      case 'f':
        return FileMeta.fromCSV(csv);
    }
    return null;
  }

  @override
  List<dynamic> toCSV() {
    return [
      key,
      name,
      status.name,
      entryModified.toIso8601String(),
    ];
  }
}
