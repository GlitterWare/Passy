import 'dart:async';
import 'package:archive/archive_io.dart';

import 'package:passy/passy_data/passy_legacy.dart';
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
    _accountsDirectory.createSync(recursive: true);
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

  void createAccount(String username, String password) {
    String _accountPath = accountsPath + Platform.pathSeparator + username;
    AccountCredentialsFile _file = AccountCredentials.fromFile(
        File(_accountPath + Platform.pathSeparator + 'credentials.json'),
        value: AccountCredentials(username, password));
    _accounts[username] = _file;
    LoadedAccount(
      path: _accountPath,
      credentials: _file,
      encrypter: getPassyEncrypter(password),
    );
  }

  void _removeAccount(String username) {
    if (_loadedAccount != null) {
      if (_loadedAccount!.username == username) {
        _loadedAccount = null;
      }
    }
    _accounts.remove(username);
    if (_accounts.isEmpty) {
      info.value.lastUsername = '';
      return;
    }
    info.value.lastUsername = _accounts.keys.first;
  }

  Future<void> removeAccount(String username) {
    _removeAccount(username);
    return Future.wait([
      info.save(),
      Directory(accountsPath + Platform.pathSeparator + username)
          .delete(recursive: true),
    ]);
  }

  void removeAccountSync(String username) {
    _removeAccount(username);
    info.saveSync();
    Directory(accountsPath + Platform.pathSeparator + username)
        .deleteSync(recursive: true);
  }

  LoadedAccount loadAccount(String username, String password) {
    _loadedAccount = convertLegacyAccount(
      path: accountsPath + Platform.pathSeparator + username,
      encrypter: getPassyEncrypter(password),
    );
    return _loadedAccount!;
  }

  void unloadAccount() => _loadedAccount = null;

  void backupAccount(String username, String outputDirectoryPath) {
    ZipFileEncoder _encoder = ZipFileEncoder();
    _encoder.zipDirectory(
        Directory(accountsPath + Platform.pathSeparator + username),
        filename:
            'passy-backup-${DateTime.now().toIso8601String().replaceAll(':', ';')}');
    _encoder.close();
  }

  void restoreAccount(String filePath, {String username = ''}) {
    ZipDecoder _decoder = ZipDecoder();
    Archive _archive = _decoder.decodeBytes(File(filePath).readAsBytesSync());
    for (final file in _archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(accountsPath + Platform.pathSeparator + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(accountsPath + Platform.pathSeparator + filename)
            .create(recursive: true);
      }
    }
  }
}
