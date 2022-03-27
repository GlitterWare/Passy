import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'loaded_account.dart';
import 'account_info.dart';
import 'passy_info.dart';

class PassyData {
  final PassyInfo passy;
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
    passy.lastUsername = _accounts.keys.first;
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
    passy.lastUsername = _accounts.keys.first;
    Directory(_accountsPath + Platform.pathSeparator + username)
        .deleteSync(recursive: true);
  }

  loadAccount(String username, String password) =>
      _loadedAccount = _accounts[username]!.load(getEncrypter(password));

  void unloadAccount() => _loadedAccount = null;

  Future<void> host() {
    return ServerSocket.bind('127.0.0.1', passy.localPort)
        .then((s) => s.listen((c) {
              StreamSubscription<Uint8List> _sub = c.listen(null);

              void _receiveData(Uint8List data) {}

              void _sendData() {
                _sub.onData(_receiveData);
              }

              void _receiveDataHashes(Uint8List data) {
                _sendData();
              }

              void _sendPasswordHashes() {
                _sub.onData(_receiveDataHashes);
                c.add(utf8.encode(jsonEncode(passwordHashes)));
              }

              void _receiveHello(Uint8List data) {
                if (utf8.decode(data) == 'PASSYHELLO') {
                  _sendPasswordHashes();
                  return;
                }
                s.close();
              }

              void _sendHello() {
                _sub.onData(_receiveHello);
                c.add(utf8.encode('PASSYHELLO'));
                c.flush();
              }

              _sendHello();
            }));
  }

  Future<void> syncronize() {
    return Socket.connect(passy.remoteAddress, passy.remotePort).then((s) {
      StreamSubscription<Uint8List> _sub = s.listen(null);

      void _receiveAndSendData(Uint8List data) {}

      void _receiveAndSendHashes(Uint8List data) {
        Map<String, String> _local = passwordHashes;
        Map<String, String> _remote = jsonDecode(utf8.decode(data));
        String _response = '{';
        for (String u in _local.keys) {
          if (_remote.containsKey(u)) {
            if (_remote[u] == _local[u]) {}
          }
        }
        s.add(utf8.encode(_response));
      }

      void _sendHello() {
        _sub.onData((d) {
          if (utf8.decode(d) == 'PASSYHELLO') {
            _sub.onData(_receiveAndSendHashes);
            s.add(utf8.encode('PASSYHELLO'));
            return;
          }
          s.close();
        });
      }

      _sendHello();
    });
    // Ask server for data hashes, if they are not the same, exchange data
  }

  PassyData(String path)
      : _accountsPath = path + Platform.pathSeparator + 'accounts',
        passy = PassyInfo(File(path + Platform.pathSeparator + 'passy.json')) {
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
