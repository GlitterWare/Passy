import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/api.dart';

class PassyBinaryFile {
  final Key _key;
  final File file;

  PassyBinaryFile({
    required this.file,
    required Key key,
  }) : _key = key;

  Future<List<int>> readAsBytes() async {
    RandomAccessFile raf = await file.open();
    int fileLen = await raf.length() - 1;
    int byte = await raf.readByte();
    int jsonLen = 1;
    // Read metadata
    List<int> meta = [];
    while (byte != 10) {
      if (byte == -1) return Uint8List(0);
      meta.add(byte);
      byte = await raf.readByte();
      jsonLen++;
    }
    int dataLen = fileLen - jsonLen;
    if (dataLen == 0) return Uint8List(0);
    int offset = jsonLen;
    //print('File length: $fileLen');
    //print('Data length: $dataLen');
    //print('Offset: $offset');
    IV? iv;
    int length = 0;
    String algo = '';
    if (meta.isNotEmpty) {
      String metaString = utf8.decode(meta);
      if (metaString[0] == '{') {
        Map<String, dynamic> metaJson = jsonDecode(metaString);
        iv = IV.fromBase64(metaJson['iv']);
        length = int.parse(metaJson['length']);
        algo = metaJson['algo'];
      } else {
        List<String> metaSplit = metaString.split(',');
        if (metaSplit.isNotEmpty) {
          iv = IV.fromBase64(metaSplit[0]);
          length = int.parse(metaSplit[1]);
          algo = metaSplit[2];
        }
      }
    }
    if (length == 0) return Uint8List(0);
    Uint8List result = Uint8List(length);
    int resultIndex = 0;
    PaddedBlockCipher _cipher = PaddedBlockCipher(algo);
    _cipher.reset();
    _cipher.init(
        false,
        PaddedBlockCipherParameters(
            ParametersWithIV<KeyParameter>(
                KeyParameter(_key.bytes), iv?.bytes ?? IV.fromLength(16).bytes),
            null));
    while (offset < fileLen) {
      Uint8List block = Uint8List(16);
      Uint8List output = Uint8List(16);
      for (int i = 0; i != 16; i++) {
        byte = await raf.readByte();
        block[i] = byte;
      }
      _cipher.processBlock(block, 0, output, 0);
      if (offset + 16 >= fileLen) {
        output = output.sublist(0, 16 - output.last);
      }
      for (int codeUnit in output) {
        result[resultIndex] = codeUnit;
        resultIndex++;
      }
      offset += 16;
      //print('Offset changed: $offset');
    }
    //print(utf8.decode(result));
    return result;
  }
}
