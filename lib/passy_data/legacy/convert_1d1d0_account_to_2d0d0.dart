import 'dart:io';

import 'package:encrypt/encrypt.dart';
import '../common.dart';

void convert1_1_0AccountTo2_0_0({
  required String path,
  required Encrypter encrypter,
}) {
  // Apply the following changes to id_cards.enc, identities.enc, notes.enc, passwords.enc, payment_cards.enc:
  // 1. Read the file and clear it.
  // 2. Decrypt entries.
  // 3. Split the decrypted entries by newlines.
  // 4. Per entry, do the following:
  // - 4.1. Retrieve the entry key from the first CSV value.
  // - 4.2. Encrypt the entry.
  // - 4.3. Join, separating with a comma (,), the entry key from 4.1 and the encrypted entry data from 4.2, adding a newline at the end.
  // - 4.4. Append the result of 4.3 to the entries file.
  void _convert(File file) {
    String _decrypted = decrypt(file.readAsStringSync(), encrypter: encrypter);
    List<String> _split = _decrypted.split('\n');
    String _result = '';
    for (String s in _split) {
      // 4
      if (s == '') continue;
      String _key = s.split(',')[0];
      _result += '$_key,${encrypt(s, encrypter: encrypter)}\n';
    }
    file.writeAsStringSync(_result);
  }

  _convert(File('$path${Platform.pathSeparator}id_cards.enc'));
  _convert(File('$path${Platform.pathSeparator}identities.enc'));
  _convert(File('$path${Platform.pathSeparator}notes.enc'));
  _convert(File('$path${Platform.pathSeparator}passwords.enc'));
  _convert(File('$path${Platform.pathSeparator}payment_cards.enc'));

  File(path + Platform.pathSeparator + 'version.txt')
      .writeAsStringSync('2.0.0');
}
