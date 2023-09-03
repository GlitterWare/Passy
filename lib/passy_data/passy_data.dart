import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/argon2_info.dart';
import 'package:passy/passy_data/auto_backup_settings.dart';
import 'package:passy/passy_data/key_derivation_type.dart';

import 'package:passy/passy_data/legacy/legacy.dart';
import 'package:passy/passy_data/local_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_info2/system_info2.dart';
import 'dart:io';

import 'account_credentials.dart';
import 'key_derivation_info.dart';
import 'passy_info.dart';

import 'common.dart' as common;
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
  final Map<String, Timer> _autoBackupTimers = {};
  LoadedAccount? _loadedAccount;

  String? getPasswordHash(String username) {
    AccountCredentialsFile? account = _accounts[username];
    if (account == null) return null;
    return account.value.passwordHash;
  }

  Future<String?> createPasswordHash(String username,
      {required String password}) async {
    AccountCredentialsFile? account = _accounts[username];
    if (account == null) return null;
    return (await common.getPasswordHash(
      password,
      derivationType: account.value.keyDerivationType,
      derivationInfo: account.value.keyDerivationInfo,
    ))
        .toString();
  }

  bool? getBioAuthEnabled(String username) =>
      _accounts[username]?.value.bioAuthEnabled;
  void setBioAuthEnabledSync(String username, bool value) {
    _accounts[username]?.value.bioAuthEnabled = value;
    _accounts[username]?.saveSync();
  }

  KeyDerivationType? getKeyDerivationType(String username) =>
      _accounts[username]?.value.keyDerivationType;

  KeyDerivationInfo? getKeyDerivationInfo(String username) {
    KeyDerivationType? type = _accounts[username]?.value.keyDerivationType;
    if (type == null) return null;
    switch (type) {
      case KeyDerivationType.none:
        return null;
      case KeyDerivationType.argon2:
        Argon2Info info =
            _accounts[username]?.value.keyDerivationInfo as Argon2Info;
        return Argon2Info(
          salt: info.salt,
          parallelism: info.parallelism,
          memory: info.memory,
          iterations: info.iterations,
        );
    }
  }

  Salt? getArgon2Salt(String username) =>
      getKeyDerivationType(username) == KeyDerivationType.argon2
          ? (_accounts[username]?.value.keyDerivationInfo as Argon2Info).salt
          : null;

  Future<DArgon2Result>? getArgon2Key(
    String username, {
    required String password,
  }) {
    AccountCredentialsFile? account = _accounts[username];
    if (account == null) return null;
    if (account.value.keyDerivationType != KeyDerivationType.argon2) {
      return null;
    }
    Argon2Info info = account.value.keyDerivationInfo as Argon2Info;
    return common.argon2ifyString(
      password,
      salt: info.salt,
      parallelism: info.parallelism,
      memory: info.memory,
      iterations: info.iterations,
    );
  }

  Future<Encrypter?> getEncrypter(
    String username, {
    required String password,
  }) async {
    AccountCredentialsFile? account = _accounts[username];
    if (account == null) return null;
    switch (account.value.keyDerivationType) {
      case KeyDerivationType.none:
        return common.getPassyEncrypter(password);
      case KeyDerivationType.argon2:
        Argon2Info info = account.value.keyDerivationInfo as Argon2Info;
        return common.getPassyEncrypterV2(
          password,
          salt: info.salt,
          parallelism: info.parallelism,
          memory: info.memory,
          iterations: info.iterations,
        );
    }
  }

  Future<Encrypter> getSyncEncrypter(
      {required String username, required String password}) {
    KeyDerivationType? type =
        getKeyDerivationType(username) ?? KeyDerivationType.none;
    return common.getSyncEncrypter(password,
        derivationType: type, derivationInfo: getKeyDerivationInfo(username));
  }

  bool hasAccount(String username) => _accounts.containsKey(username);

  PassyData(String path)
      : passyPath = path,
        accountsPath = path + Platform.pathSeparator + 'accounts',
        info = PassyInfo.fromFile(
            File(path + Platform.pathSeparator + 'passy.json')) {
    bool isInfoChanged = false;
    if (info.value.version != common.passyVersion) {
      info.value.version = common.passyVersion;
      isInfoChanged = true;
    }
    if (info.value.deviceId.isEmpty) {
      Random random = Random.secure();
      info.value.deviceId =
          '${DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c')}-${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}';
      isInfoChanged = true;
    }
    if (isInfoChanged) info.saveSync();
    refreshAccounts();
    if (!_accounts.containsKey(info.value.lastUsername)) {
      if (_accounts.isEmpty) {
        info.value.lastUsername = '';
      } else {
        info.value.lastUsername = _accounts.keys.first;
      }
      info.saveSync();
    }
  }

  void refreshAccounts() {
    _accounts.clear();
    Directory _accountsDirectory =
        Directory(passyPath + Platform.pathSeparator + 'accounts');
    _accountsDirectory.createSync(recursive: true);
    List<FileSystemEntity> _accountDirectories = _accountsDirectory.listSync();
    for (Timer t in _autoBackupTimers.values) {
      t.cancel();
    }
    _autoBackupTimers.clear();
    for (FileSystemEntity d in _accountDirectories) {
      String _username = d.path.split(Platform.pathSeparator).last;
      _accounts[_username] = AccountCredentials.fromFile(
        File(accountsPath +
            Platform.pathSeparator +
            _username +
            Platform.pathSeparator +
            'credentials.json'),
        value:
            AccountCredentials(username: _username, passwordHash: 'corrupted'),
      );
      LocalSettingsFile _localSettings = LocalSettings.fromFile(
        File(accountsPath +
            Platform.pathSeparator +
            _username +
            Platform.pathSeparator +
            'local_settings.json'),
      );
      AutoBackupSettings? _autoBackup = _localSettings.value.autoBackup;
      if (_autoBackup != null) {
        void _autoBackupCycle() {
          backupAccount(
              username: _username, outputDirectoryPath: _autoBackup.path);
          _autoBackup.lastBackup = DateTime.now().toUtc();
          _localSettings.saveSync();
          _autoBackupTimers[_username] = Timer(
            Duration(milliseconds: _autoBackup.backupInterval),
            _autoBackupCycle,
          );
        }

        int _timeDelta = DateTime.now().toUtc().millisecondsSinceEpoch -
            _autoBackup.lastBackup.millisecondsSinceEpoch;
        if (_timeDelta >= _autoBackup.backupInterval) {
          _autoBackupCycle();
          return;
        }
        _autoBackupTimers[_username] = Timer(
          Duration(milliseconds: _autoBackup.backupInterval - _timeDelta),
          _autoBackupCycle,
        );
      }
    }
  }

  Future<void> createAccount(String username, String password) async {
    String _accountPath = accountsPath + Platform.pathSeparator + username;
    Salt _salt = Salt.newSalt();
    int _memory = SysInfo.getFreePhysicalMemory();
    if (_memory > 67108864) {
      _memory = 65536;
    } else if (_memory > 33554432) {
      _memory = 32768;
    } else if (_memory > 16777216) {
      _memory = 16384;
    } else if (_memory > 8388608) {
      _memory = 8192;
    } else if (_memory > 4194304) {
      _memory = 4096;
    } else if (_memory > 2097152) {
      _memory = 2048;
    }
    DArgon2Result result =
        await common.argon2ifyString(password, salt: _salt, memory: _memory);
    AccountCredentialsFile _file = AccountCredentials.fromFile(
        File(_accountPath + Platform.pathSeparator + 'credentials.json'),
        value: AccountCredentials(
          username: username,
          passwordHash: sha512.convert(result.rawBytes).toString(),
          keyDerivationType: KeyDerivationType.argon2,
          keyDerivationInfo: Argon2Info(salt: _salt, memory: _memory),
        ));
    File(_accountPath + Platform.pathSeparator + 'version.txt')
      ..createSync()
      ..writeAsStringSync(common.accountVersion);
    _accounts[username] = _file;
    await info.reload();
    LoadedAccount.fromDirectory(
      path: _accountPath,
      credentials: _file,
      encrypter: common
          .getPassyEncrypterFromBytes(Uint8List.fromList(result.rawBytes)),
      syncEncrypter:
          await getSyncEncrypter(username: username, password: password),
      deviceId: info.value.deviceId,
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

  Future<LoadedAccount> loadAccount(
      String username, Encrypter encrypter, Encrypter syncEncrypter) async {
    await info.reload();
    _loadedAccount = loadLegacyAccount(
      path: accountsPath + Platform.pathSeparator + username,
      encrypter: encrypter,
      syncEncrypter: syncEncrypter,
      deviceId: info.value.deviceId,
      credentials: _accounts[username],
    );
    return _loadedAccount!;
  }

  void unloadAccount() {
    LoadedAccount? acc = _loadedAccount;
    if (acc != null) acc.stopAutoSync();
    _loadedAccount = null;
  }

  Future<String> backupAccount({
    required String username,
    required String outputDirectoryPath,
    String? fileName,
  }) async {
    if (fileName == null) {
      fileName = outputDirectoryPath +
          Platform.pathSeparator +
          'passy-backup-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
    } else {
      fileName = outputDirectoryPath + Platform.pathSeparator + fileName;
    }
    ZipFileEncoder _encoder = ZipFileEncoder();
    String _accountPath = accountsPath + Platform.pathSeparator + username;
    _encoder.create(fileName, level: 9);
    await _encoder.addDirectory(Directory(_accountPath));
    _encoder.close();
    return fileName;
  }

  Future<String> restoreAccount(
    String backupPath, {
    required String password,
  }) async {
    String _tempPath = (await getTemporaryDirectory()).path +
        Platform.pathSeparator +
        'passy-restore-' +
        DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
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
    {
      AccountCredentialsFile creds = AccountCredentials.fromFile(
          File(_tempAccountPath + Platform.pathSeparator + 'credentials.json'));
      Encrypter encrypter = await common.getPasswordEncrypter(password,
          derivationType: creds.value.keyDerivationType,
          derivationInfo: creds.value.keyDerivationInfo);
      Encrypter syncEncrypter = await common.getSyncEncrypter(password,
          derivationInfo: creds.value.keyDerivationInfo,
          derivationType: creds.value.keyDerivationType);
      await info.reload();
      LoadedAccount _account = loadLegacyAccount(
          path: _tempAccountPath,
          encrypter: encrypter,
          deviceId: info.value.deviceId,
          syncEncrypter: syncEncrypter)!;
      _account.bioAuthEnabled = false;
      _account.clearRemovedHistory();
      _account.renewHistory();
      _account.clearRemovedFavorites();
      _account.renewFavorites();
      await _account.save();
      _username = _account.username;
    }
    // Able to load the account, safe to replace
    _newAccountPath = accountsPath + Platform.pathSeparator + _username;
    _newAccountDir = Directory(_newAccountPath);
    unloadAccount();
    if (await _newAccountDir.exists()) {
      await _newAccountDir.delete(recursive: true);
    }
    await _newAccountDir.create(recursive: true);
    await common.copyDirectory(
      Directory(_tempAccountPath),
      _newAccountDir,
    );
    refreshAccounts();
    await _tempPathDir.delete(recursive: true);
    return _username;
  }

  Future<String> importAccount(String path,
      {required Encrypter encrypter, required Encrypter syncEncrypter}) async {
    String _tempPath = (await getTemporaryDirectory()).path +
        Platform.pathSeparator +
        'passy-restore-' +
        DateTime.now().toUtc().toIso8601String().replaceAll(':', ';');
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
    Archive _archive = _decoder.decodeBytes(await File(path).readAsBytes());
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
    Directory _tempAccountDir = Directory(_tempAccountPath);
    {
      await info.reload();
      LoadedAccount _account = JSONLoadedAccount.fromDirectory(
              path: _tempAccountPath, deviceId: info.value.deviceId)
          .toEncryptedCSVLoadedAccount(encrypter, syncEncrypter);
      await _tempAccountDir.delete(recursive: true);
      await _tempAccountDir.create();
      _account.bioAuthEnabled = false;
      await _account.save();
      _username = _account.username;
    }
    // Able to load the account, safe to replace
    _newAccountPath = accountsPath + Platform.pathSeparator + _username;
    _newAccountDir = Directory(_newAccountPath);
    unloadAccount();
    if (await _newAccountDir.exists()) {
      await _newAccountDir.delete(recursive: true);
    }
    await _newAccountDir.create(recursive: true);
    await common.copyDirectory(
      Directory(_tempAccountPath),
      _newAccountDir,
    );
    refreshAccounts();
    await _tempPathDir.delete(recursive: true);
    return _username;
  }

  Future<void> changeAccountUsername(
      String username, String newUsername) async {
    if (newUsername.length < 2) throw 'Username is shorter than 2 letters';
    if (_accounts.containsKey(newUsername)) throw 'Username is already in use';
    AccountCredentials _creds;
    {
      AccountCredentialsFile _credsFile = _accounts[username]!;
      _creds = _credsFile.value;
      _accounts.remove(username);
      _credsFile.value.username = newUsername;
      await _credsFile.save();
    }
    await Directory(passyPath +
            Platform.pathSeparator +
            'accounts' +
            Platform.pathSeparator +
            username)
        .rename(passyPath +
            Platform.pathSeparator +
            'accounts' +
            Platform.pathSeparator +
            newUsername);
    _accounts[newUsername] = AccountCredentialsFile(
        File(
          passyPath +
              Platform.pathSeparator +
              'accounts' +
              Platform.pathSeparator +
              newUsername +
              Platform.pathSeparator +
              'credentials.json',
        ),
        fromJson: AccountCredentials.fromJson,
        value: _creds);
    info.value.lastUsername = newUsername;
    await info.save();
  }
}
