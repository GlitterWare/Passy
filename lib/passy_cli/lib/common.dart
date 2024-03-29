import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:dargon2/dargon2.dart';
import 'package:passy/passy_data/argon2_info.dart';
import 'package:passy/passy_data/common.dart' as pcommon;
import 'package:passy/passy_data/key_derivation_info.dart';
import 'package:passy/passy_data/key_derivation_type.dart';

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

List<List<String>> parseCommand(String command) {
  bool isEscaped = false;
  String curStr = '';
  List<List<String>> result = [[]];
  int resultIndex = 0;
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
        continue;
      }
    }
    if (!isSingleQuoted) {
      if (c == '"') {
        isDoubleQuoted = !isDoubleQuoted;
        continue;
      }
    }
    if (!isDoubleQuoted && !isSingleQuoted) {
      if (c == ' ') {
        if (curStr != '') {
          switch (curStr) {
            case '&&':
              curStr = '';
              result.add([]);
              resultIndex++;
              continue;
            case ';':
              curStr = '';
              result.add([]);
              resultIndex++;
              continue;
          }
          result[resultIndex].add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    curStr += c;
  }
  if (curStr != '') result[resultIndex].add(curStr);
  return result;
}

Future<Key> derivePassword(String password,
    {required KeyDerivationType derivationType,
    KeyDerivationInfo? derivationInfo}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      int byteSize = utf8.encode(password).length;
      if (byteSize > 32) {
        throw Exception(
            'Password is longer than 32 bytes. If you\'re using 32 characters, try using 16 and then 8 characters.');
      }
      int a = 32 - byteSize;
      password += ' ' * a;
      return Key.fromUtf8(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return Key(Uint8List.fromList((await argon2ifyString(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      ))
          .rawBytes));
  }
}

Future<DArgon2Result> argon2ifyString(
  String s, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
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
  int memory = 65536,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2ifyString(password,
      salt: salt,
      parallelism: parallelism,
      memory: memory,
      iterations: iterations);
  return Encrypter(AES(Key(Uint8List.fromList(result.rawBytes))));
}

Future<Digest> getArgon2Hash(
  String password, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
  int iterations = 2,
}) async {
  List<int> derivedPassword = (await argon2ifyString(
    password,
    salt: salt,
    parallelism: parallelism,
    memory: memory,
    iterations: iterations,
  ))
      .rawBytes;
  return sha512.convert(derivedPassword);
}

Future<Digest> getPasswordHash(
  String password, {
  required KeyDerivationType derivationType,
  KeyDerivationInfo? derivationInfo,
}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      return pcommon.getPassyHash(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return await getArgon2Hash(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      );
  }
}

Future<Encrypter> getPassyEncrypterV2(
  String password, {
  required Salt salt,
  int parallelism = 4,
  int memory = 65536,
  int iterations = 2,
}) async {
  DArgon2Result result = await argon2ifyString(password,
      salt: salt,
      parallelism: parallelism,
      memory: memory,
      iterations: iterations);
  return Encrypter(AES(Key(Uint8List.fromList(result.rawBytes))));
}

Future<Encrypter> getPasswordEncrypter(
  String password, {
  required KeyDerivationType derivationType,
  KeyDerivationInfo? derivationInfo,
}) async {
  switch (derivationType) {
    case KeyDerivationType.none:
      return pcommon.getPassyEncrypter(password);
    case KeyDerivationType.argon2:
      Argon2Info info = derivationInfo as Argon2Info;
      return getPassyEncrypterV2(
        password,
        salt: info.salt,
        parallelism: info.parallelism,
        memory: info.memory,
        iterations: info.iterations,
      );
  }
}
