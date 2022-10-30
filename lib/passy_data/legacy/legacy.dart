import 'package:encrypt/encrypt.dart';
import 'dart:io';

import '../account_credentials.dart';
import '../common.dart';
import '../loaded_account.dart';
import 'convert_pre_1d1d0_account_to_1d1d0.dart';

class Pre0d3d0Account implements Exception {
  final String? message;

  Pre0d3d0Account(this.message);

  @override
  String toString() {
    String _str = 'Pre0d3d0Account';
    if (message != null) _str += ': $message';
    return _str;
  }
}

bool canLoadAccountVersion(String accVersion) {
  List<int> _accVersion =
      accVersion.split('.').map((e) => int.parse(e)).toList();
  List<int> _appVersion =
      accountVersion.split('.').map((e) => int.parse(e)).toList();
  if (_appVersion[0] > _accVersion[0]) return true;
  if (_appVersion[0] < _accVersion[0]) return false;
  if (_appVersion[1] > _accVersion[1]) return true;
  if (_appVersion[1] < _accVersion[1]) return false;
  if (_appVersion[2] > _accVersion[2]) return true;
  if (_appVersion[2] < _accVersion[2]) return false;
  return true;
}

void convertLegacyAccount({
  required String path,
  required Encrypter encrypter,
}) {
  List<int> _accountVersion;
  File _versionFile = File(path + Platform.pathSeparator + 'version.txt');
  if (_versionFile.existsSync()) {
    _accountVersion = _versionFile
        .readAsStringSync()
        .split('.')
        .map((e) => int.parse(e))
        .toList();
  } else {
    _accountVersion = [0, 0, 0];
  }
  if (_accountVersion.join('.') == accountVersion) return;
  {
    String _exception =
        'Account version is higher than the supported account version. Please make sure that you are using the latest release of Passy before loading this account. Account version: ${_accountVersion.join('.')}, Supported account version: $accountVersion';
    if (!canLoadAccountVersion(_accountVersion.join('.'))) throw (_exception);
  }
  if (_accountVersion[0] == 0) {
    if (_accountVersion[1] < 3) {
      throw Pre0d3d0Account(
          'Pre 0.3.0 accounts are not converted starting from Passy v1.2.0 (account version 1.1.0)');
    }
  }
  if (_accountVersion[0] == 1) {
    if (_accountVersion[1] < 1) {
      // Pre 1.1.0 conversion
      convertPre1d1d0AccountTo1d1d0(path: path, encrypter: encrypter);
    }
  }
  // No conversion
  _versionFile.writeAsStringSync(accountVersion);
}

LoadedAccount? loadLegacyAccount({
  required String path,
  required Encrypter encrypter,
  AccountCredentialsFile? credentials,
}) {
  convertLegacyAccount(path: path, encrypter: encrypter);
  return LoadedAccount.fromDirectory(
    path: path,
    encrypter: encrypter,
    credentials: credentials,
  );
}
