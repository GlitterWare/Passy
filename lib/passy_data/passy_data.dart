import 'dart:async';

import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'loaded_account.dart';
import 'account_info.dart';
import 'passy_info.dart';

class PassyData {
  final PassyInfo info;
  bool get noAccounts => _accounts.isEmpty;
  Iterable<String> get usernames => _accounts.keys;
  Map<String, String> get passwordHashes =>
      _accounts.map((key, value) => MapEntry(key, value.passwordHash));
  LoadedAccount? get loadedAccount => _loadedAccount;

  final String _accountsPath;
  final Map<String, AccountInfo> _accounts = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) => _accounts[username]!.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  void createAccount(
      String username, String password, String icon, Color color) {
    AccountInfo _info = AccountInfo(
      _accountsPath + Platform.pathSeparator + username,
      username: username,
      password: password,
      icon: icon,
      color: color,
    );
    _accounts[username] = _info;
    _info.load(getEncrypter(password));
  }

  Future<void> removeAccount(String username) {
    if (_loadedAccount != null) {
      if (_loadedAccount!.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    info.lastUsername = _accounts.keys.first;
    return Directory(_accountsPath + Platform.pathSeparator + username)
        .delete(recursive: true);
  }

  void removeAccountSync(String username) {
    if (_loadedAccount != null) {
      if (_loadedAccount!.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    info.lastUsername = _accounts.keys.first;
    Directory(_accountsPath + Platform.pathSeparator + username)
        .deleteSync(recursive: true);
  }

  loadAccount(String username, String password) =>
      _loadedAccount = _accounts[username]!.load(getEncrypter(password));

  void unloadAccount() => _loadedAccount = null;

  PassyData(String path)
      : _accountsPath = path + Platform.pathSeparator + 'accounts',
        info = PassyInfo(File(path + Platform.pathSeparator + 'passy.json')) {
    Directory _accountsDirectory =
        Directory(path + Platform.pathSeparator + 'accounts');
    _accountsDirectory.createSync();
    List<FileSystemEntity> _accountDirectories = _accountsDirectory.listSync();
    for (FileSystemEntity d in _accountDirectories) {
      String _username = d.path.split(Platform.pathSeparator).last;
      _accounts[_username] = AccountInfo.fromDirectory(d.path);
    }
  }
}
