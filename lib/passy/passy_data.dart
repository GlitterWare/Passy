import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/passy/common.dart';
import 'package:passy/passy/loaded_account.dart';

import 'account_data.dart';
import 'account_info.dart';
import 'app_data.dart';

class AppData {
  final PassyData passy;
  bool get noAccounts => _accounts.isEmpty;
  Iterable<String> get usernames => _accounts.keys;
  LoadedAccount? get loadedAccount => _loadedAccount;

  final String _accountsPath;
  Map<String, AccountInfo> _accounts = {};
  Map<String, File> _dataFiles = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) => _accounts[username]!.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  void createAccount(
      String username, String password, String icon, Color color) {
    String _path = _accountsPath + Platform.pathSeparator + username;
    _accounts[username] = AccountInfo.create(
      File(_path + Platform.pathSeparator + 'info.json'),
      username,
      password,
      icon: icon,
      color: color,
    );
    File _dataFile = File(_path + Platform.pathSeparator + 'data.json');
    AccountData.loadOrCreate(_dataFile, getEncrypter(password));
    _dataFiles[username] = _dataFile;
  }

  Future<void> removeAccount(String username) async {
    if (_loadedAccount != null) {
      if (_loadedAccount!.accountInfo.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    await Directory(_accountsPath + Platform.pathSeparator + username)
        .delete(recursive: true);
  }

  loadAccount(String username, String password) {
    AccountInfo _info = _accounts[username]!;
    _loadedAccount =
        LoadedAccount(_info, _dataFiles[username]!, getEncrypter(password));
  }

  void unloadAccount() => _loadedAccount = null;

  static PassyData _constructAppData(File file) {
    if (!file.existsSync()) {
      return PassyData(file,
          version: '0.0.0', lastUsername: '', theme: ThemeMode.system);
    }
    return PassyData.fromFile(file);
  }

  AppData(String path)
      : _accountsPath = path + Platform.pathSeparator + 'accounts',
        passy = _constructAppData(
            File(path + Platform.pathSeparator + 'passy.json')) {
    Directory _accountsDirectory =
        Directory(path + Platform.pathSeparator + 'accounts');
    _accountsDirectory.createSync();
    List<FileSystemEntity> _accountFolders = _accountsDirectory.listSync();
    for (FileSystemEntity _account in _accountFolders) {
      String _username = _account.path.split(Platform.pathSeparator).last;
      _accounts[_username] = AccountInfo.fromFile(
          File(_account.path + Platform.pathSeparator + 'info.json'));
      _dataFiles[_username] =
          File(_account.path + Platform.pathSeparator + 'data.json');
    }
  }
}
