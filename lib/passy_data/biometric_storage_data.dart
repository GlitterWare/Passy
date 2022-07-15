import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:flutter_locker/flutter_locker.dart';

class BiometricStorageData with JsonConvertable {
  final String key;
  String password;

  BiometricStorageData({
    required this.key,
    this.password = '',
  });

  BiometricStorageData.fromJson(
      {required this.key, required Map<String, dynamic> json})
      : password = json['password'] ?? '';

  static Future<BiometricStorageData> fromLocker(String key) async {
    try {
      return BiometricStorageData(
          key: key,
          password: jsonDecode(await FlutterLocker.retrieve(
                  RetrieveSecretRequest(
                      key: key,
                      androidPrompt: AndroidPrompt(
                          title: 'Authenticate', cancelLabel: 'Cancel'),
                      iOsPrompt: IOsPrompt(
                          touchIdText: 'Authenticate'))))['password'] ??
              '');
    } catch (e) {
      return BiometricStorageData(key: key);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'password': password,
      };

  Future<void> save() => FlutterLocker.save(SaveSecretRequest(
      key: key,
      secret: jsonEncode(toJson()),
      androidPrompt: AndroidPrompt(
          title: 'Enable biometric authentication', cancelLabel: 'Cancel')));
}
