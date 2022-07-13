import 'dart:async';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';

import 'package:passy/passy_data/passy_legacy.dart';
import 'package:path_provider/path_provider.dart';
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

  final String passyPath;
  final String accountsPath;
  final Map<String, AccountCredentialsFile> _accounts = {};
  LoadedAccount? _loadedAccount;

  String getPasswordHash(String username) =>
      _accounts[username]!.value.passwordHash;
  bool hasAccount(String username) => _accounts.containsKey(username);

  PassyData(String path)
      : passyPath = path,
        accountsPath = path + Platform.pathSeparator + 'accounts',
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
    File(_accountPath + Platform.pathSeparator + 'version.txt')
      ..createSync()
      ..writeAsStringSync(accountVersion);
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

  LoadedAccount loadAccount(String username, Encrypter encrypter) {
    _loadedAccount = convertLegacyAccount(
      path: accountsPath + Platform.pathSeparator + username,
      encrypter: encrypter,
    );
    return _loadedAccount!;
  }

  void unloadAccount() => _loadedAccount = null;

  void backupAccount(String username, String outputDirectoryPath) {
    ZipFileEncoder _encoder = ZipFileEncoder();
    String _accountPath = accountsPath + Platform.pathSeparator + username;
    _encoder.create(outputDirectoryPath +
        Platform.pathSeparator +
        'passy-backup-$username-${DateTime.now().toIso8601String().replaceAll(':', ';')}.zip');
    _encoder.addDirectory(Directory(_accountPath));
    _encoder.close();
  }

  Future<LoadedAccount> restoreAccount(String backupPath,
      {required Encrypter encrypter}) async {
    String _tempPath = (await getTemporaryDirectory()).path +
        Platform.pathSeparator +
        'passy-restore-' +
        DateTime.now().toIso8601String().replaceAll(':', ';');
    Directory _tempPathDir = Directory(_tempPath);
    if (await _tempPathDir.exists()) {
      await _tempPathDir.delete(recursive: true);
    }
    await _tempPathDir.create(recursive: true);
    String _username;
    String _tempAccountPath;
    String _newAccountPath;
    Directory _newAccountDir;
    ZipDecoder _decoder = ZipDecoder();
    Archive _archive =
        _decoder.decodeBytes(await File(backupPath).readAsBytes());
    for (final file in _archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        await File(_tempPath + Platform.pathSeparator + filename)
            .create(recursive: true)
            .then((value) => value.writeAsBytes(data));
      } else {
        await Directory(_tempPath + Platform.pathSeparator + filename)
            .create(recursive: true);
      }
    }
    _username = _archive.first.name.split('/')[0];
    _tempAccountPath = _tempPath + Platform.pathSeparator + _username;
    LoadedAccount(path: _tempAccountPath, encrypter: encrypter);
    // Able to load the account, safe to replace
    _newAccountPath = accountsPath + Platform.pathSeparator + _username;
    _newAccountDir = Directory(_newAccountPath);
    unloadAccount();
    if (await _newAccountDir.exists()) {
      await _newAccountDir.delete(recursive: true);
    }
    await _newAccountDir.create(recursive: true);
    await copyDirectory(
      Directory(_tempAccountPath),
      _newAccountDir,
    );
    _accounts[_archive.first.name] = AccountCredentials.fromFile(
        File(_newAccountPath + Platform.pathSeparator + 'credentials.json'));
    await _tempPathDir.delete(recursive: true);
    return LoadedAccount(path: _newAccountPath, encrypter: encrypter);
  }

  Future<BiometricStorageData> getAccountBiometricStorageData(
      String username) async {
    BiometricStorageFile _file = await BiometricStorage().getStorage(username);
    String _fileRead = (await _file.read())!;
    if (_fileRead.isNotEmpty) {
      return BiometricStorageData.fromJson(jsonDecode(_fileRead));
    }
    return BiometricStorageData();
  }
}
