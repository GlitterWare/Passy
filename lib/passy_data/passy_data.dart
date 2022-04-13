import 'dart:async';

import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'passy_info.dart';

import 'common.dart';
import 'loaded_account.dart';

class PassyData {
  final PassyInfoFile info;
  bool get noAccounts => _accounts.isEmpty;
  Iterable<String> get usernames => _accounts.keys;
  Map<String, String> get passwordHashes =>
      _accounts.map((key, value) => MapEntry(key, value.value.passwordHash));
  LoadedAccount? get loadedAccount => _loadedAccount;

  final String accountsPath;
  final Map<String, AccountCredentialsFile> _accounts = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) =>
      _accounts[username]!.value.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  void createAccount(String username, String password) {
    String _accountPath = accountsPath + Platform.pathSeparator + username;
    AccountCredentialsFile _file = AccountCredentials.fromFile(
        File(_accountPath + Platform.pathSeparator + 'credentials.json'),
        value: AccountCredentials(username, password));
    _accounts[username] = _file;
    LoadedAccount(
      _file,
      path: _accountPath,
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

  LoadedAccount loadAccount(String username, String password) =>
      _loadedAccount = LoadedAccount(_accounts[username]!,
          path: accountsPath + Platform.pathSeparator + username,
          encrypter: getEncrypter(password));

  void unloadAccount() => _loadedAccount = null;

  PassyData(String path)
      : accountsPath = path + Platform.pathSeparator + 'accounts',
        info = PassyInfo.fromFile(
            File(path + Platform.pathSeparator + 'passy.json')) {
    if (info.value.version != passyVersion) {
      info.value.version = passyVersion;
      info.saveSync();
    }
    Directory _accountsDirectory =
        Directory(path + Platform.pathSeparator + 'accounts');
    _accountsDirectory.createSync();
    List<FileSystemEntity> _accountDirectories = _accountsDirectory.listSync();
    for (FileSystemEntity d in _accountDirectories) {
      String _username = d.path.split(Platform.pathSeparator).last;
      _accounts[_username] = AccountCredentials.fromFile(
        File(accountsPath +
            Platform.pathSeparator +
            _username +
            Platform.pathSeparator +
            'credentials.json'),
        value: AccountCredentials(_username, 'corrupted'),
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
