import 'dart:convert';
import 'dart:typed_data';

import 'passy_entry.dart';

class PassyBytes extends PassyEntry<PassyBytes> {
  static const csvTemplate = {
    'key': 1,
    'value': 2,
  };

  Uint8List value;

  PassyBytes(String key, {required this.value}) : super(key);

  PassyBytes.fromJson(Map<String, dynamic> json)
      : value = base64Decode(json['value']),
        super(json['key']);

  factory PassyBytes.fromCSV(List<List<String>> csv,
      {Map<String, Map<String, int>> templates = const {}}) {
    // TODO: implement fromCSV
    throw UnimplementedError();
  }

  @override
  int compareTo(PassyBytes other) => key.compareTo(other.key);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'value': base64Encode(value),
      };

  @override
  toCSV() {
    // TODO: implement toCSV
    throw UnimplementedError();
  }
}
