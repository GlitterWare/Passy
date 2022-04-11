import 'package:passy/passy_data/json_convertable.dart';

abstract class PassyEntry<T> implements JsonConvertable {
  final String key;
  int compareTo(T other);

  PassyEntry(this.key);
}
