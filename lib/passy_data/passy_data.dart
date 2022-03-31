import 'dart:async';

import 'package:passy/passy_data/passy_info_file.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'loaded_account.dart';
import 'account_info.dart';

class PassyData {
  final PassyInfoFile info;
  bool get noAccounts => _accounts.isEmpty;
  Iterable<String> get usernames => _accounts.keys;
  Map<String, String> get passwordHashes =>
      _accounts.map((key, value) => MapEntry(key, value.passwordHash));
  LoadedAccount? get loadedAccount => _loadedAccount;

  final String accountsPath;
  final Map<String, AccountInfo> _accounts = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) => _accounts[username]!.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  void createAccount(AccountInfo info, String password) {
    _accounts[info.username] = info;
    LoadedAccount(
      info,
      path: accountsPath + Platform.pathSeparator + info.username,
      encrypter: getEncrypter(password),
    );
  }

  Future<void> removeAccount(String username) {
    if (_loadedAccount != null) {
      if (_loadedAccount!.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    info.value.lastUsername = _accounts.keys.first;
    return Directory(accountsPath + Platform.pathSeparator + username)
        .delete(recursive: true);
  }

  void removeAccountSync(String username) {
    if (_loadedAccount != null) {
      if (_loadedAccount!.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    info.value.lastUsername = _accounts.keys.first;
    Directory(accountsPath + Platform.pathSeparator + username)
        .deleteSync(recursive: true);
  }

  loadAccount(String username, String password) =>
      _loadedAccount = LoadedAccount(_accounts[username]!,
          path: accountsPath + Platform.pathSeparator + username,
          encrypter: getEncrypter(password));

  void unloadAccount() => _loadedAccount = null;

  PassyData(String path)
      : accountsPath = path + Platform.pathSeparator + 'accounts',
        info =
            PassyInfoFile(File(path + Platform.pathSeparator + 'passy.json')) {
    Directory _accountsDirectory =
        Directory(path + Platform.pathSeparator + 'accounts');
    _accountsDirectory.createSync();
    List<FileSystemEntity> _accountDirectories = _accountsDirectory.listSync();
    for (FileSystemEntity d in _accountDirectories) {
      String _username = d.path.split(Platform.pathSeparator).last;
      _accounts[_username] = AccountInfo.fromFile(
        File(accountsPath +
            Platform.pathSeparator +
            _username +
            Platform.pathSeparator +
            'info.json'),
      );
    }
    if (!_accounts.containsKey(info.value.lastUsername)) {
      if (_accounts.isEmpty) {
        info.value.lastUsername = '';
      } else {
        info.value.lastUsername = _accounts.keys.first;
      }
      info.saveSync();
    }
  }
}
