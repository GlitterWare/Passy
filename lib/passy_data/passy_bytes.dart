import 'dart:convert';
import 'dart:typed_data';

import 'common.dart';
import 'passy_entry.dart';

class PassyBytes extends PassyEntry<PassyBytes> {
  static const csvSchema = {
    'key': 1,
    'value': 2,
  };

  Uint8List value;

  PassyBytes(String key, {required this.value}) : super(key);

  PassyBytes.fromJson(Map<String, dynamic> json)
      : value = base64Decode(json['value']),
        super(json['key']);

  factory PassyBytes.fromCSV(List<List<dynamic>> csv,
      {Map<String, Map<String, int>> schemas = const {
        'passyBytes': csvSchema
      }}) {
    // TODO: implement fromCSV
    Map<String, int> _passyBytesSchema = schemas['passyBytes'] ?? csvSchema;
    List<dynamic> _csv = csv[0];
    return PassyBytes(
      _csv[_passyBytesSchema['key']!],
      value: base64Decode(_csv[_passyBytesSchema['key']!]),
    );
  }

  @override
  int compareTo(PassyBytes other) => key.compareTo(other.key);

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'value': base64Encode(value),
      };

  @override
  List<List> toCSV() => jsonToCSV(toJson());
}
