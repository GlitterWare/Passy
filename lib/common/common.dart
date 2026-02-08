import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/passy_data/passy_cloud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;
import 'package:xdg_directories/xdg_directories.dart';
import 'package:passy/l10n/app_localizations.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
late PassyData data;
late AppLocalizations localizations;

Future<Directory> getDocumentsDirectory() async {
  if (Platform.isLinux) {
    {
      Directory? xdgDir = getUserDirectory('DOCUMENTS');
      if (xdgDir != null) {
        try {
          if (!await xdgDir.exists()) {
            await xdgDir.create(recursive: true);
          }
          return xdgDir;
        } catch (_) {}
      }
    }

    Directory documentsDir;

    Future<Directory> createFallback() async {
      documentsDir = Directory(path_lib.join(
        (Platform.environment['HOME'] ??
            path_lib.join(
              '/',
              'home',
              Platform.environment['USER'],
            )),
        'Documents',
      ));
      if (!(await documentsDir.exists())) {
        await documentsDir.create(recursive: true);
      }
      return documentsDir;
    }

    try {
      documentsDir = await getApplicationDocumentsDirectory();
    } catch (_) {
      return createFallback();
    }
    if (!(await documentsDir.exists())) return createFallback();
    return documentsDir;
  }
  return await getApplicationDocumentsDirectory();
}

Future<PassyData> loadPassyData() async {
  return PassyData(
      (await getDocumentsDirectory()).path + Platform.pathSeparator + 'Passy');
}

void loadLocalizations(BuildContext context) {
  localizations = AppLocalizations.of(context)!;
}

Future<String> getLatestVersion() async {
  try {
    String _version = (jsonDecode(await http.read(
      Uri.https('api.github.com', 'repositories/469494355/releases/latest'),
    ))['tag_name'] as String);
    if (_version[0] == 'v') {
      _version = _version.substring(1);
    }
    return _version;
  } catch (_) {
    return passyVersion;
  }
}

class PassyCloudLoop {
  static bool _errorNotified = false;
  static bool _versionMismatch = false;
  static bool _passwordSet = false;
  static bool _started = false;

  static final StreamController<PassyCloudSyncStatus> _statusController =
      StreamController<PassyCloudSyncStatus>.broadcast();
  static Stream<PassyCloudSyncStatus> get status => _statusController.stream;

  static Future<void> _cloudSync() async {
    final _account = data.loadedAccount;
    if (_account == null || !_account.cloudEnabled) {
      _errorNotified = false;
      _versionMismatch = false;
      _passwordSet = false;
      return;
    }
    if (_versionMismatch) return;
    String? token = _account.cloudToken;
    if (token == null) return;
    Password? newPassword;
    if (!_passwordSet) {
      newPassword = _account.getPassword('gw_cloud_new');
      // Cloud enabled and nothing to set
      if (newPassword == null) _passwordSet = true;
    }
    try {
      final status = await PassyCloud.subscriptionStatus(token: token);
      if (status.subscriptions.isEmpty) return;
    } catch (e) {
      if (e is! PassyCloudError) {
        // Ignore connection errors
        if (e is http.ClientException || e is SocketException) {
          return;
        } else {
          rethrow;
        }
      }
      //#region Refresh token
      if (e.statusCode == HttpStatus.unauthorized) {
        final resp = (await PassyCloud.refresh(
            refreshToken: _account.cloudRefreshToken!));
        _account.cloudToken = resp.token;
        _account.cloudRefreshToken = resp.refresh;
        await _account.saveSettings();
      }
      //#endregion
      return;
    }
    await PassyCloud.synchronize(
        token: token,
        account: _account,
        calculateHash: (bytes) => sha256.convert(bytes).toString(),
        onSyncProgress: (status) async {
          //#region Refresh token
          if (status == PassyCloudSyncStatus.unauthorized) {
            final resp = await PassyCloud.refresh(
                refreshToken: _account.cloudRefreshToken!);
            _account.cloudToken = resp.token;
            _account.cloudRefreshToken = resp.refresh;
            await _account.saveSettings();
          }
          //#endregion
          _statusController.add(status);
        });
    if (newPassword != null) {
      _passwordSet = true;
      if (!_account.passwordExists('gw_cloud')) {
        newPassword = Password(
          key: 'gw_cloud',
          nickname: newPassword.nickname,
          email: newPassword.email,
          password: newPassword.password,
          websites: newPassword.websites,
        );
        _account.setPassword(newPassword);
      }
      _account.removePassword('gw_cloud_new');
      await _account.saveSettings();
    }
  }

  static Future<void> _cloudLoop() async {
    try {
      await _cloudSync();
    } catch (e) {
      if (e is! PassyCloudError && e is! StateError) rethrow;
      if (e is PassyCloudError) {
        if (e.source == 'convertLegacyAccount') {
          // Cloud version is newer than local, pause Cloud sync
          _versionMismatch = true;
        }
      }
      if (!_errorNotified) {
        _errorNotified = true;
        rethrow;
      }
    } finally {
      Future.delayed(Duration(seconds: 4, milliseconds: Random().nextInt(1000)),
          _cloudLoop);
    }
  }

  static void start() {
    if (_started) return;
    _started = true;
    _cloudLoop();
  }
}
