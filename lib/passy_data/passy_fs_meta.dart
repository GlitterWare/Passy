import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/folder_meta.dart';

class PassyFsMeta with CSVConvertable {
  final String key;
  final String name;

  PassyFsMeta({
    String? key,
    required this.name,
  }) : key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c');

  static PassyFsMeta? fromCSV(List<dynamic> csv) {
    if (csv.length == 4) {
      return PassyFsMeta(
        key: csv[0],
        name: csv[1],
      );
    }
    switch (csv[4]) {
      case 'd':
        return FolderMeta.fromCSV(csv);
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
    ];
  }
}
