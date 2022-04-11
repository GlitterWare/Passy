import 'dart:convert';
import 'dart:typed_data';

import 'passy_entry.dart';

class PassyBytes extends PassyEntry<PassyBytes> {
  Uint8List value;

  PassyBytes(String key, {required this.value}) : super(key);

  PassyBytes.fromJson(Map<String, dynamic> json)
      : value = base64Decode(json['value']) ?? Uint8List(0),
        super(json['key']);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'value': base64Encode(value),
      };

  @override
  int compareTo(PassyBytes other) => key.compareTo(other.key);
}
