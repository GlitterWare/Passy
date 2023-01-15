import 'package:passy/passy_data/json_convertable.dart';

abstract class EntryMeta with JsonConvertable {
  final String key;

  EntryMeta(this.key);
}
