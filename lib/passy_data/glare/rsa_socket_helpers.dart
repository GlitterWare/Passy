import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';

abstract class RSASocketHelpers {
  static Map<String, dynamic>? decodeData(List<int> data,
      {Encrypter? encrypter}) {
    if (encrypter == null) return null;
    List<String> utfMessages = [];
    Map<String, List<int>> binaryObjects = {};
    Map<String, dynamic> decoded = {};
    try {
      String decrypted = '';
      List<int> curMsg = [];
      Uint8List? curBobj;
      int bobjIndex = 0;
      List<int> command = [];
      IV? bobjIv;
      String? bobjKey;
      List<int> leftToReadList = [];
      bool isEscaped = false;
      bool isCommand = false;
      int? leftToReadState;
      int leftToRead = 0;
      for (int i = 0; i != data.length; i++) {
        int n = data[i];
        if (leftToReadState != null) {
          switch (leftToReadState) {
            case 0:
              if (n == 60) {
                isCommand = true;
                leftToReadState = null;
                List<dynamic> leftToReadCSV;
                try {
                  String leftToReadString = utf8.decode(leftToReadList);
                  leftToReadCSV = csvDecode(leftToReadString);
                } catch (_) {
                  leftToReadList.clear();
                  leftToReadState = null;
                  continue;
                }
                if (leftToReadCSV.length < 3) {
                  leftToReadList.clear();
                  leftToReadState = null;
                  continue;
                }
                leftToReadList.clear();
                try {
                  leftToRead = int.parse(leftToReadCSV[0]);
                  bobjIv = IV.fromBase64(leftToReadCSV[1]);
                  bobjKey = encrypter.decrypt64(leftToReadCSV[2], iv: bobjIv);
                  curBobj = Uint8List(leftToRead);
                } catch (_) {
                  leftToReadList.clear();
                  leftToReadState = null;
                  continue;
                }
                continue;
              }
              leftToReadList.add(n);
              continue;
            case 1:
              curBobj![bobjIndex] = n;
              leftToRead -= 1;
              bobjIndex += 1;
              if (leftToRead == 0) {
                leftToReadState = null;
                binaryObjects[bobjKey!] =
                    encrypter.decryptBytes(Encrypted(curBobj), iv: bobjIv);
                bobjIv = null;
                bobjKey = null;
                curBobj = null;
              }
              continue;
          }
        }
        if (isCommand) {
          if (n == 62) {
            isCommand = false;
            if (command.isEmpty) continue;
            String commandString;
            try {
              commandString = utf8.decode(command);
            } catch (_) {
              command.clear();
              continue;
            }
            command.clear();
            switch (commandString) {
              case 'bobj':
                leftToReadState = 0;
                break;
              case '/bobj':
                leftToReadState = 1;
                break;
            }
          } else if (command.length < 8) {
            command.add(n);
          }
          continue;
        }
        if (isEscaped) {
          isEscaped = false;
          curMsg.add(92);
          continue;
        }
        switch (n) {
          case 32:
            utfMessages.add(utf8.decode(curMsg));
            curMsg.clear();
            break;
          case 60:
            isCommand = true;
            break;
          case 92:
            isEscaped = true;
            break;
          default:
            curMsg.add(n);
            break;
        }
      }
      if (curMsg.isNotEmpty) {
        utfMessages.add(utf8.decode(curMsg));
        curMsg.clear();
      }
      for (String part in utfMessages) {
        List<String> partSplit = part.split(',');
        if (partSplit.length < 2) return null;
        IV iv = IV.fromBase64(partSplit[0]);
        String data = encrypter.decrypt64(partSplit[1], iv: iv);
        decrypted += data;
      }
      decoded = jsonDecode(decrypted);
      decoded.remove('binaryObjects');
      if (binaryObjects.isNotEmpty) decoded['binaryObjects'] = binaryObjects;
    } catch (_) {
      return null;
    }
    return decoded;
  }

  static void writeJson(
    Map<String, dynamic> data, {
    required Socket socket,
    Map<String, List<int>>? binaryObjects,
    Encrypter? encrypter,
  }) {
    if (encrypter == null) return;
    String encoded = jsonEncode(data);
    IV _iv = IV.fromSecureRandom(16);
    encoded = _iv.base64 + ',' + encrypter.encrypt(encoded, iv: _iv).base64;
    socket.write(encoded);
    if (binaryObjects != null) {
      for (String key in binaryObjects.keys) {
        List<int> val = binaryObjects[key]!;
        IV _iv = IV.fromSecureRandom(16);
        List<int> bytes = encrypter.encryptBytes(val, iv: _iv).bytes;
        socket.write(
            ' \\<bobj\\>${bytes.length},${_iv.base64},${encrypter.encrypt(key, iv: _iv).base64}\\</bobj\\>');
        socket.write('<r>${bytes.length}</r>');
        socket.add(bytes);
      }
    }
    socket.write('\n');
  }
}
