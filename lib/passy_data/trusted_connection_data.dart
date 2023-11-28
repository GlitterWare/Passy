import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/json_convertable.dart';

class TrustedConnectionData with JsonConvertable {
  String deviceId;
  DateTime version;

  TrustedConnectionData({
    required this.deviceId,
    required this.version,
  });

  TrustedConnectionData.fromJson(Map<String, dynamic> json)
      : deviceId = json['deviceId'] ?? '',
        version = json.containsKey('version')
            ? DateTime.parse(json['version'])
            : DateTime.now().toUtc();

  factory TrustedConnectionData.fromEncrypted({
    required String data,
    required Encrypter encrypter,
  }) {
    List<String> encryptedSplit = data.split(',');
    IV iv = IV.fromBase64(encryptedSplit[0]);
    String decrypted = decrypt(encryptedSplit[1], encrypter: encrypter, iv: iv);
    return TrustedConnectionData.fromJson(jsonDecode(decrypted));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'version': version.toIso8601String(),
    };
  }

  String toEncrypted(Encrypter encrypter) {
    IV iv = IV.fromSecureRandom(16);
    return '${iv.base64},${encrypt(jsonEncode(toJson()), encrypter: encrypter, iv: iv)}';
  }
}
