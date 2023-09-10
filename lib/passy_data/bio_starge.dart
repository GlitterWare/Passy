import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_locker/flutter_locker.dart';
import 'package:passy/passy_data/common.dart';

import '../common/common.dart';
import 'biometric_storage_data.dart';

extension BioStorage on BiometricStorageData {
  static Future<BiometricStorageData> fromLocker(String key) async {
    try {
      return BiometricStorageData(
          key: key,
          password: jsonDecode(await FlutterLocker.retrieve(
                  RetrieveSecretRequest(
                      key: key,
                      androidPrompt: AndroidPrompt(
                          title: localizations.authenticate,
                          cancelLabel: localizations.cancel),
                      iOsPrompt: IOsPrompt(
                          touchIdText:
                              localizations.authenticate))))['password'] ??
              '');
    } catch (e) {
      return BiometricStorageData(key: key);
    }
  }

  static Future<bool> authenticate(String username) async {
    BiometricStorageData _bioData;
    try {
      _bioData = await BioStorage.fromLocker(username);
    } catch (e) {
      return false;
    }
    if ((await data.createPasswordHash(username, password: _bioData.password))
            .toString() !=
        data.getPasswordHash(username)) return false;
    data.info.value.lastUsername = username;
    await data.info.save();
    Key key =
        (await data.derivePassword(username, password: _bioData.password))!;
    await data.loadAccount(
      username,
      getPassyEncrypterFromBytes(key.bytes),
      await data.getSyncEncrypter(
          username: username, password: _bioData.password),
      key,
    );
    return true;
  }

  Future<void> save() => FlutterLocker.save(SaveSecretRequest(
      key: key,
      secret: jsonEncode(toJson()),
      androidPrompt: AndroidPrompt(
          title: 'Enable biometric authentication', cancelLabel: 'Cancel')));
}
