import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:dargon2/dargon2.dart';

String getBoxMessage(String message) {
  List<String> msgSplit = message.split('\n');
  int maxLength = 0;
  for (String line in msgSplit) {
    if (line.length > maxLength) maxLength = line.length;
  }
  String result = ' ${'_' * (maxLength + 2)}\n';
  for (String line in msgSplit) {
    result += '| $line${' ' * (maxLength - line.length)} |\n';
  }
  result += '|${'_' * (maxLength + 2)}|';
  return result;
}

List<String> parseCommand(String command) {
  bool isEscaped = false;
  String curStr = '';
  List<String> result = [];
  bool isSingleQuoted = false;
  bool isDoubleQuoted = false;
  for (int i = 0; i != command.length; i++) {
    String c = command[i];
    if (isEscaped) {
      curStr += c;
      isEscaped = false;
      continue;
    } else if (c == '\\') {
      isEscaped = true;
      continue;
    }
    if (!isDoubleQuoted) {
      if (c == '\'') {
        isSingleQuoted = !isSingleQuoted;
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    if (!isSingleQuoted) {
      if (c == '"') {
        isDoubleQuoted = !isDoubleQuoted;
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    if (!isDoubleQuoted && !isSingleQuoted) {
      if (c == ' ') {
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    curStr += c;
  }
  if (curStr != '') result.add(curStr);
  return result;
}

Future<DArgon2Result> argon2ifyString(
  String s, {
  required Salt salt,
  int parallelism = 4,
  int memory = 64,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2.hashPasswordString(
    s,
    salt: salt,
    parallelism: parallelism,
    memory: memory,
    iterations: iterations,
    length: 32,
  );
  return result;
}

Future<Encrypter> getPassyEncrypterV2Dart(
  String password, {
  required Salt salt,
  int parallelism = 4,
  int memory = 64,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2ifyString(password,
      salt: salt,
      parallelism: parallelism,
      memory: memory,
      iterations: iterations);
  return Encrypter(AES(Key(Uint8List.fromList(result.rawBytes))));
}
