import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:otp/otp.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:base32/base32.dart';

enum TFAType {
// ignore: constant_identifier_names
  TOTP,
// ignore: constant_identifier_names
  HOTP,
// ignore: constant_identifier_names
  Steam,
}

TFAType? tfaTypeFromName(String name) {
  switch (name) {
    case 'TOTP':
      return TFAType.TOTP;
    case 'HOTP':
      return TFAType.HOTP;
    case 'Steam':
      return TFAType.Steam;
  }
  return null;
}

Algorithm? algorithmFromName(String name) {
  switch (name) {
    case 'SHA1':
      return Algorithm.SHA1;
    case 'SHA256':
      return Algorithm.SHA256;
    case 'SHA512':
      return Algorithm.SHA512;
  }
  return null;
}

class TFA with JsonConvertable, CSVConvertable {
  String secret;
  int length;
  int interval;
  Algorithm algorithm;
  bool isGoogle;
  TFAType type;

  TFA({
    this.secret = '',
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
    this.isGoogle = true,
    this.type = TFAType.TOTP,
  });

  TFA.fromJson(Map<String, dynamic> json)
      : secret = json['secret'],
        length = json['length'],
        interval = json['interval'],
        algorithm = algorithmFromName(json['algorithm']) ?? Algorithm.SHA1,
        isGoogle = json['isGoogle'] ?? true,
        type = tfaTypeFromName(json['type']) ?? TFAType.TOTP;

  factory TFA.fromCSV(List csv) {
    if (csv.length == 5) csv.add(TFAType.TOTP.name);
    return TFA(
        secret: csv[0],
        length: int.tryParse(csv[1]) ?? 6,
        interval: int.tryParse(csv[2]) ?? 30,
        algorithm: algorithmFromName(csv[3]) ?? Algorithm.SHA1,
        isGoogle: boolFromString(csv[4]) ?? true,
        type: tfaTypeFromName(csv[5]) ?? TFAType.TOTP);
  }

  @override
  Map<String, dynamic> toJson() => {
        'secret': secret,
        'length': length,
        'interval': interval,
        'algorithm': algorithm.name,
        'isGoogle': isGoogle,
        'type': type.name,
      };

  @override
  List toCSV() => [
        secret,
        length.toString(),
        interval.toString(),
        algorithm.name,
        isGoogle.toString(),
        type.name,
      ];

  String _generateTOTP() {
    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      length: length,
      interval: interval,
      algorithm: algorithm,
      isGoogle: isGoogle,
    );
  }

  String _generateHOTP() {
    return OTP.generateHOTPCodeString(
      secret,
      interval,
      length: length,
      algorithm: algorithm,
      isGoogle: isGoogle,
    );
  }

  Future<String> _generateSteam() async {
    var time = ByteData(8)
      ..setUint32(0, 0, Endian.big)
      ..setUint32(
          4,
          ((DateTime.now().millisecondsSinceEpoch / 1000).floor() / 30).floor(),
          Endian.big);
    Hmac hmac = Hmac(sha1, base32.decode(secret));
    Digest digest = hmac.convert(time.buffer.asUint8List());
    var bytes = digest.bytes;
    var start = bytes[19] & 0x0F;
    var code = bytes.sublist(start, start + 4);
    var totp =
        Uint8List.fromList(code).buffer.asByteData().getUint32(0, Endian.big) &
            0x7FFFFFFF;
    const chars = '23456789BCDFGHJKMNPQRTVWXY';
    String result = '';
    for (int i = 0; i != 5; i++) {
      result += chars[(totp % chars.length).toInt()];
      totp ~/= chars.length;
    }
    return result;
  }

  Future<String> generate() async {
    switch (type) {
      case TFAType.TOTP:
        return _generateTOTP();
      case TFAType.HOTP:
        return _generateHOTP();
      case TFAType.Steam:
        return _generateSteam();
    }
  }
}
