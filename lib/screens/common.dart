import 'dart:io';

import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'main_screen.dart';
import 'passwords_screen.dart';

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.notes: '',
  Screen.idCards: '',
  Screen.identities: '',
};

final bool _isMobile = Platform.isAndroid || Platform.isIOS;

Future<bool> bioAuth(String username) async {
  BiometricStorageData _bioData;
  try {
    _bioData = await BiometricStorageData.fromLocker(username);
  } catch (e) {
    return false;
  }
  if (getPassyHash(_bioData.password).toString() !=
      data.getPasswordHash(username)) return false;
  data.info.value.lastUsername = username;
  await data.info.save();
  data.loadAccount(username, getPassyEncrypter(_bioData.password));
  return true;
}

void openUrl(String url) {
  if (_isMobile) {
    FlutterWebBrowser.openWebPage(url: url);
    return;
  }
  launchUrlString(url);
}
