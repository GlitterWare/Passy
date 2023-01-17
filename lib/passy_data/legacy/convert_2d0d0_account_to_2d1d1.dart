import 'dart:io';

import 'package:encrypt/encrypt.dart';
import '../common.dart';

void convert2_0_0AccountTo2_1_0({
  required String path,
  required Encrypter encrypter,
}) {
  // Apply the following changes to id_cards.enc, identities.enc, notes.enc, passwords.enc, payment_cards.enc:
  // 1. Read file line by line.
  // 2. Per line do the following:
  // - 2.1. Decrypt the entry.
  // - 2.2. Generate a random IV of length 16.
  // - 2.3. Encrypt the entry with the random IV.
  // - 2.4. Join, separating with the comma (,), entry key, the random IV and the encrypted entry.
  // - 2.5. Rewrite the result of 2.4. as the line contents.
  void _convert(File file) {
    File _fileTemp = File('${file.path}_temp');
    if (!_fileTemp.existsSync()) {
      _fileTemp = file.copySync(_fileTemp.path);
    }
    file.writeAsStringSync('');
    RandomAccessFile _fileTempRaf = _fileTemp.openSync(mode: FileMode.read);
    RandomAccessFile _file = file.openSync(mode: FileMode.append);
    processLines(_fileTempRaf, onLine: (line, eofReached) {
      List<String> _decoded = line.split(',');
      IV _iv = IV.fromSecureRandom(16);
      String _reencrypted;
      {
        String _decrypted = decrypt(_decoded[1], encrypter: encrypter);
        _reencrypted = encrypt(_decrypted, encrypter: encrypter, iv: _iv);
      }
      _file.writeStringSync('${_decoded[0]},${_iv.base64},$_reencrypted\n');
      return null;
    });
    _file.closeSync();
    _fileTempRaf.closeSync();
    _fileTemp.deleteSync();
  }

  _convert(File('$path${Platform.pathSeparator}id_cards.enc'));
  _convert(File('$path${Platform.pathSeparator}identities.enc'));
  _convert(File('$path${Platform.pathSeparator}notes.enc'));
  _convert(File('$path${Platform.pathSeparator}passwords.enc'));
  _convert(File('$path${Platform.pathSeparator}payment_cards.enc'));

  File(path + Platform.pathSeparator + 'version.txt')
      .writeAsStringSync('2.1.0');
}
