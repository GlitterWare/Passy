import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:otp/otp.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:base32/base32.dart';
import 'package:convert/convert.dart';

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
  String _secret;
  String _secretFormatted = '';
  int length;
  int interval;
  Algorithm algorithm;
  bool isGoogle;
  TFAType type;

  void _formatHex() {
    // Format hex
    if (_secret.contains('0') ||
        _secret.contains('1') ||
        _secret.contains('8') ||
        _secret.contains('9')) {
      _secretFormatted = base32.encode(Uint8List.fromList(hex.decode(_secret)));
    } else {
      _secretFormatted = _secret;
    }
  }

  String get secret => _secret;
  set secret(String value) {
    _secret = value;
    _formatHex();
  }

  TFA({
    String secret = '',
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
    this.isGoogle = true,
    this.type = TFAType.TOTP,
  }) : _secret = secret {
    _formatHex();
  }

  TFA.fromJson(Map<String, dynamic> json)
      : _secret = json['secret'],
        length = json['length'],
        interval = json['interval'],
        algorithm = algorithmFromName(json['algorithm']) ?? Algorithm.SHA1,
        isGoogle = json['isGoogle'] ?? true,
        type =
            tfaTypeFromName(json['type'] ?? TFAType.TOTP.name) ?? TFAType.TOTP {
    _formatHex();
  }

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
        'secret': _secret,
        'length': length,
        'interval': interval,
        'algorithm': algorithm.name,
        'isGoogle': isGoogle,
        'type': type.name,
      };

  @override
  List toCSV() => [
        _secret,
        length.toString(),
        interval.toString(),
        algorithm.name,
        isGoogle.toString(),
        type.name,
      ];

  String _generateTOTP() {
    try {
      return OTP.generateTOTPCodeString(
        _secretFormatted,
        DateTime.now().millisecondsSinceEpoch,
        length: length,
        interval: interval,
        algorithm: algorithm,
        isGoogle: isGoogle,
      );
    } catch (_) {
      if (_secretFormatted == _secret) rethrow;
      String secretHex = base32.encode(Uint8List.fromList(hex.decode(_secret)));
      bool ok = true;
      try {
        return OTP.generateTOTPCodeString(
          secretHex,
          DateTime.now().millisecondsSinceEpoch,
          length: length,
          interval: interval,
          algorithm: algorithm,
          isGoogle: isGoogle,
        );
      } catch (_) {
        ok = false;
      }
      if (!ok) rethrow;
    }
  }

  String _generateHOTP() {
    try {
      return OTP.generateHOTPCodeString(
        _secretFormatted,
        interval,
        length: length,
        algorithm: algorithm,
        isGoogle: isGoogle,
      );
    } catch (_) {
      if (_secretFormatted == _secret) rethrow;
      String secretHex = base32.encode(Uint8List.fromList(hex.decode(_secret)));
      bool ok = true;
      try {
        return OTP.generateHOTPCodeString(
          secretHex,
          interval,
          length: length,
          algorithm: algorithm,
          isGoogle: isGoogle,
        );
      } catch (_) {
        ok = false;
      }
      if (!ok) rethrow;
    }
  }

  String _generateSteam() {
    var time = ByteData(8)
      ..setUint32(0, 0, Endian.big)
      ..setUint32(
          4,
          ((DateTime.now().millisecondsSinceEpoch / 1000).floor() / 30).floor(),
          Endian.big);
    Hmac hmac = Hmac(sha1, base32.decode(_secret));
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

  String generate() {
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
