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

  Future<void> encrypt({
    required File input,
    IV? iv,
    String algorithm = 'AES/SIC/PKCS7',
  }) async {
    iv ??= IV.fromSecureRandom(16);
    if (!await file.exists()) await file.create(recursive: true);
    RandomAccessFile rafOut = await file.open(mode: FileMode.write);
    int inLen = await input.length();
    Uint8List contents = await input.readAsBytes();
    Uint8List copyList =
        Uint8List(contents.length + (16 - (contents.length % 16)));
    for (int i = 0; i != contents.length; i++) {
      copyList[i] = contents[i];
    }
    contents = copyList;
    copyList = Uint8List(0);
    if (inLen == 0) {
      rafOut.writeString('');
      return;
    }
    int fileIndex = 0;
    PaddedBlockCipher _cipher = PaddedBlockCipher(algorithm);
    _cipher.reset();
    _cipher.init(
        true,
        PaddedBlockCipherParameters(
            ParametersWithIV<KeyParameter>(KeyParameter(_key.bytes), iv.bytes),
            null));
    await rafOut.writeString('${iv.base64},$inLen,$algorithm\n');
    while (fileIndex <= inLen) {
      Uint8List blockIn = Uint8List(16);
      Uint8List blockOut = Uint8List(16);
      for (int i = 0; i != 16; i++) {
        if (fileIndex + i >= contents.length) break;
        int byte = contents[fileIndex + i];
        blockIn[i] = byte;
      }
      if (fileIndex + 16 > inLen) {
        int blockInFree = (16 - (inLen - fileIndex));
        for (int i = 16 - blockInFree; i < 16; i++) {
          blockIn[i] = blockInFree;
        }
      }
      _cipher.processBlock(blockIn, 0, blockOut, 0);
      for (int i = 0; i != 16; i++) {
        contents[fileIndex + i] = blockOut[i];
      }
      fileIndex += 16;
    }
    await rafOut.writeFrom(contents);
    await rafOut.close();
    return;
  }

  Future<Uint8List> readAsBytes() async {
    RandomAccessFile raf = await file.open();
    int fileLen = await raf.length();
    int byte = raf.readByteSync();
    int jsonLen = 1;
    // Read metadata
    List<int> meta = [];
    while (byte != 10) {
      if (byte == -1) return Uint8List(0);
      meta.add(byte);
      byte = raf.readByteSync();
      jsonLen++;
    }
    await raf.close();
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
    Uint8List contents = await file.readAsBytes();
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
        byte = contents[offset + i];
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

  Stream<int> streamAsBytes() async* {
    RandomAccessFile raf = await file.open();
    int fileLen = await raf.length();
    int byte = raf.readByteSync();
    int jsonLen = 1;
    // Read metadata
    List<int> meta = [];
    while (byte != 10) {
      if (byte == -1) return;
      meta.add(byte);
      byte = raf.readByteSync();
      jsonLen++;
    }
    await raf.close();
    int dataLen = fileLen - jsonLen;
    if (dataLen == 0) return;
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
    if (length == 0) return;
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
        byte = raf.readByteSync();
        block[i] = byte;
      }
      _cipher.processBlock(block, 0, output, 0);
      if (offset + 16 >= fileLen) {
        output = output.sublist(0, 16 - output.last);
      }
      for (int codeUnit in output) {
        yield codeUnit;
      }
      offset += 16;
      //print('Offset changed: $offset');
    }
    await raf.close();
  }
}
