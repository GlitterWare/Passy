import 'package:passy/passy_data/csv_convertable.dart';

abstract class PassyFsMeta with CSVConvertable {
  final String key;

  PassyFsMeta({
    String? key,
  }) : key = key ??
            DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c');
}
