import 'dart:io';

import 'package:passy/passy_data/account_info.dart';
import 'package:passy/passy_data/json_file.dart';

class AccountInfoFile extends JsonFile<AccountInfo> {
  AccountInfoFile(File file, {required AccountInfo value})
      : super(file, value: value) {
    file.createSync(recursive: true);
    saveSync();
  }
}
