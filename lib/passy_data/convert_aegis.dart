import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:otp/otp.dart' as otp;
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:pointycastle/block/aes.dart';

TFAType? _aegisTypeToTFAType(String type) {
  switch (type) {
    case 'totp':
      return TFAType.TOTP;
    case 'hotp':
      return TFAType.HOTP;
    case 'steam':
      return TFAType.Steam;
  }
  return null;
}

otp.Algorithm? _aegisAlgoToTFAType(String algo) {
  switch (algo) {
    case 'SHA1':
      return otp.Algorithm.SHA1;
    case 'SHA256':
      return otp.Algorithm.SHA256;
    case 'SHA512':
      return otp.Algorithm.SHA512;
  }
  return null;
}

List<Password> _convertAegis(Map<String, dynamic> db) {
  String keyPrefix = '${DateTime.now().toUtc().toIso8601String()}-import';
  List<Password> result = [];
  var entries = db['entries'];
  int i = 0;
  for (var entry in entries) {
    var name = entry['name'];
    var type = entry['type'];
    TFAType? tfaType = _aegisTypeToTFAType(type);
    if (tfaType == null) continue;
    var info = entry['info'];
    if (info is! Map<String, dynamic>) continue;
    var algo = info['algo'];
    otp.Algorithm? tfaAlgo = _aegisAlgoToTFAType(algo);
    if (tfaAlgo == null) continue;
    var secret = info.containsKey('secret') ? info['secret'] : '';
    var digits = info.containsKey('digits') ? info['digits'] : 6;
    var period = info.containsKey('period')
        ? info['period']
        : (info.containsKey('counter')
            ? info['counter']
            : (tfaType == TFAType.HOTP)
                ? 0
                : 30);
    TFA tfa = TFA(
      type: tfaType,
      algorithm: tfaAlgo,
      secret: secret,
      length: digits,
      interval: period,
      isGoogle: tfaType != TFAType.Steam,
    );
    var issuer = entry['issuer'];
    var note = entry['note'];
    String additionalInfo = '';
    List<CustomField> customFields = [];
    if (issuer != null) {
      customFields.add(CustomField(title: 'Issuer', value: issuer));
    }
    if (note != null) additionalInfo = note;

    String key = '$keyPrefix-$i';
    result.add(Password(
      key: key,
      nickname: name,
      tfa: tfa,
      additionalInfo: additionalInfo,
      customFields: customFields,
    ));
    i++;
  }
  return result;
}

List<Password> convertAegis({required File aegisFile, String? password}) {
  String contents = aegisFile.readAsStringSync();
  var json = jsonDecode(contents);
  var db = json['db'];
  if (db is Map<String, dynamic>) {
    return _convertAegis(db);
  }
  if (password == null) throw 'No password provided for encrypted Aegis export';
  var header = json['header'];
  var slots = header['slots'];
  Uint8List? decryptedKey;
  for (var slot in slots) {
    if (slot['type'] != 1) continue;
    var key = slot['key'];
    var keyParams = slot['key_params'];
    var nonce = keyParams['nonce'];
    var tag = keyParams['tag'];
    var n = slot['n'];
    var r = slot['r'];
    var p = slot['p'];
    var salt = slot['salt'];
    var scrypt = Scrypt();
    scrypt.init(
        ScryptParameters(n, r, p, 32, Uint8List.fromList(hex.decode(salt))));
    var derivedKey = scrypt.process(Uint8List.fromList(utf8.encode(password)));
    var cipher = GCMBlockCipher(AESEngine());
    cipher.init(
        false,
        AEADParameters(
          KeyParameter(derivedKey),
          16 * 8,
          Uint8List.fromList(hex.decode(nonce)),
          Uint8List(0),
        ));
    decryptedKey = cipher
        .process(Uint8List.fromList([...hex.decode(key), ...hex.decode(tag)]));
  }
  var params = header['params'];
  var nonce = params['nonce'];
  var tag = params['tag'];
  var cipher = GCMBlockCipher(AESEngine());
  cipher.init(
      false,
      AEADParameters(
        KeyParameter(decryptedKey!),
        16 * 8,
        Uint8List.fromList(hex.decode(nonce)),
        Uint8List(0),
      ));
  var dbDecrypted = cipher
      .process(Uint8List.fromList([...base64Decode(db), ...hex.decode(tag)]));
  var dbDecoded = utf8.decode(dbDecrypted);
  var dbJson = jsonDecode(dbDecoded);
  return _convertAegis(dbJson);
}
