import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passy/passy/common.dart';
import 'package:passy/passy/loaded_account.dart';
import 'package:universal_io/io.dart';

import 'account_data.dart';
import 'account_info.dart';
import 'passy_data.dart';

class AppData {
  final PassyData passy;
  bool get noAccounts => _accounts.isEmpty;
  Iterable<String> get usernames => _accounts.keys;
  LoadedAccount? get loadedAccount => _loadedAccount;

  final String _accountsPath;
  final Map<String, AccountInfo> _accounts = {};
  final Map<String, File> _dataFiles = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) => _accounts[username]!.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  void createAccount(
      String username, String password, String icon, Color color) {
    String _path = _accountsPath + Platform.pathSeparator + username;
    _accounts[username] = AccountInfo(
      File(_path + Platform.pathSeparator + 'info.json'),
      username,
      password,
      icon: icon,
      color: color,
    );
    File _dataFile = File(_path + Platform.pathSeparator + 'data.json');
    AccountData(_dataFile, getEncrypter(password));
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

  Future<void> host() async {
    await ServerSocket.bind('127.0.0.1', passy.localPort)
        .then((s) => s.listen((_client) async {
              print(_client.address);
              _client.add(utf8.encode('{"hello": "world"}'));
              _client.flush();
            }));
  }

  Future<void> syncronize() async {
    await Socket.connect(passy.remoteAddress, passy.remotePort)
        .then((s) => s.listen((d) async {
              Map<String, dynamic> _data = jsonDecode(utf8.decode(d));
              print(_data);
            }));
    // Ask server for data hashes, if they are not the same, exchange data
  }

  AppData(String path)
      : _accountsPath = path + Platform.pathSeparator + 'accounts',
        passy = PassyData(File(path + Platform.pathSeparator + 'passy.json')) {
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
