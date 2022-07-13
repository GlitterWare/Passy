import 'dart:convert';

import 'package:passy/passy_data/json_convertable.dart';
import 'package:flutter_locker/flutter_locker.dart';

class BiometricStorageData with JsonConvertable {
  final String key;
  String _password;

  String get password => _password;
  Future<void> setPassword(String value) {
    _password = value;
    return FlutterLocker.save(SaveSecretRequest(
        key: key,
        secret: jsonEncode(toJson()),
        androidPrompt: AndroidPrompt(
            title: 'Enable biometric authentication', cancelLabel: 'Cancel')));
  }

  BiometricStorageData({
    required this.key,
    password = '',
  }) : _password = password;

  BiometricStorageData.fromJson(
      {required this.key, required Map<String, dynamic> json})
      : _password = json['password'];

  static Future<BiometricStorageData> fromLocker(String key) async =>
      BiometricStorageData(
          key: key,
          password: jsonDecode(await FlutterLocker.retrieve(
                  RetrieveSecretRequest(
                      key: key,
                      androidPrompt: AndroidPrompt(
                          title: 'Authenticate', cancelLabel: 'Cancel'),
                      iOsPrompt: IOsPrompt(
                          touchIdText: 'Authenticate'))))['password'] ??
              '');

  @override
  Map<String, dynamic> toJson() => {
        'password': _password,
      };
}
