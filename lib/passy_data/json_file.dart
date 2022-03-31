import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/json_file_base.dart';
import 'package:universal_io/io.dart';

class JsonFile<T extends JsonConvertable> implements SaveableFileBase {
  final T value;
  final File _file;

  @override
  Future<void> save() => _file.writeAsString(jsonEncode(value));
  @override
  void saveSync() => _file.writeAsStringSync(jsonEncode(value));

  JsonFile(this._file, {required this.value});
}
