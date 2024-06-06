import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/file_meta.dart';

abstract class PassyFsMeta with CSVConvertable {
  final String key;
  final bool? synchronized;
  List<String> tags;
  String name;
  final String virtualPath;

  PassyFsMeta({
    String? key,
    this.synchronized,
    List<String>? tags,
    required this.name,
    required this.virtualPath,
  })  : tags = tags ?? [],
        key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c');

  static PassyFsMeta? fromCSV(List<dynamic> csv) {
    switch (csv[5]) {
      case 'f':
        return FileMeta.fromCSV(csv);
    }
    return null;
  }
}
