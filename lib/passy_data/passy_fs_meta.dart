import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/file_meta.dart';

abstract class PassyFsMeta with CSVConvertable {
  final String key;
  final String name;
  final String virtualPath;

  PassyFsMeta({
    String? key,
    required this.name,
    required this.virtualPath,
  }) : key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c');

  static PassyFsMeta? fromCSV(List<dynamic> csv) {
    switch (csv[2]) {
      case 'f':
        return FileMeta.fromCSV(csv);
    }
    return null;
  }
}
