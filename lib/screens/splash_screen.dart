import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:passy/main.dart';
import 'package:path/path.dart' as path_lib;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/add_account_screen.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/screens/common.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    loadLocalizations(context);
    setOnError(context);
    Future<void> showUpdateDialog() {
      return showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: PassyTheme.dialogShape,
          title: Text(localizations.newVersionAvailable),
          content: ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SvgPicture.asset(
                'assets/images/github_icon.svg',
                width: 26,
                colorFilter: const ColorFilter.mode(
                    PassyTheme.lightContentColor, BlendMode.srcIn),
              ),
            ),
            center: Text(localizations.download),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                openUrl('https://github.com/GlitterWare/Passy/releases/latest'),
          ),
        ),
      );
    }

    Future<File?> _getTemporaryCliExecutable() async {
      String suffix = Platform.isWindows ? '.exe' : '';
      String scriptSuffix = Platform.isWindows ? '.bat' : '.sh';
      Directory installDir = File(Platform.resolvedExecutable).parent;
      File original =
          File(installDir.path + Platform.pathSeparator + 'passy_cli' + suffix);
      File originalScript = File(installDir.path +
          Platform.pathSeparator +
          'passy_cli_native_messaging' +
          scriptSuffix);
      File scriptCopy;
      try {
        if (!(await original.exists())) return null;
        if (!(await originalScript.exists())) return null;
        Directory copyDir = Directory(
          (await getDocumentsDirectory()).path +
              Platform.pathSeparator +
              'Passy' +
              Platform.pathSeparator +
              'passy_cli' +
              Platform.pathSeparator +
              'temp' +
              Platform.pathSeparator +
              'bin' +
              Platform.pathSeparator +
              'passy_cli',
        );
        if (await copyDir.exists()) {
          List<FileSystemEntity> files =
              await copyDir.list(recursive: true).toList();
          for (FileSystemEntity file in files) {
            try {
              if ((await file.stat()).type == FileSystemEntityType.directory) {
                Directory dir = Directory(file.path);
                bool allClear = true;
                for (FileSystemEntity file
                    in (await (dir.list(recursive: true)).toList())) {
                  try {
                    if ((await file.stat()).type ==
                        FileSystemEntityType.directory) continue;
                    await File(file.path).writeAsString('');
                    await file.delete();
                  } catch (_) {
                    allClear = false;
                  }
                }
                if (allClear) await dir.delete(recursive: true);
                continue;
              }
              // Write to test if the file is locked (required on Unix systems)
              await File(file.path).writeAsString('');
              await file.delete();
            } catch (_) {}
          }
        } else {
          await copyDir.create(recursive: true);
        }
        // Note: can't use semicolons as replacement on Windows
        // due to native messaging limitations.
        // Can't use commas on Firefox or Windows Chromium
        String date = DateTime.now().toIso8601String().replaceAll(':', 'c');
        Directory tempCopyDir =
            Directory(copyDir.path + Platform.pathSeparator + date);
        await tempCopyDir.create();
        String filename = 'passy_cli';
        String copyPath =
            tempCopyDir.path + Platform.pathSeparator + filename + suffix;
        await original.copy(copyPath);
        String scriptCopyPath = tempCopyDir.path +
            Platform.pathSeparator +
            'passy_cli_native_messaging' +
            scriptSuffix;
        scriptCopy = await originalScript.copy(scriptCopyPath);
      } catch (_) {
        return null;
      }
      return scriptCopy;
    }

    Future<File?> _prepareManifest(String cliTempPath) async {
      Directory installDir = File(Platform.resolvedExecutable).parent;
      File nativeManifestFile = File(installDir.path +
          Platform.pathSeparator +
          'passy_cli_native_messaging.json');
      File copyFile;
      try {
        String contents = await nativeManifestFile.readAsString();
        Map<String, dynamic> contentsDecoded = jsonDecode(contents);
        contentsDecoded['path'] = cliTempPath;
        contents = jsonEncode(contentsDecoded);
        Directory copyDir = Directory(
          (await getDocumentsDirectory()).path +
              Platform.pathSeparator +
              'Passy' +
              Platform.pathSeparator +
              'passy_cli',
        );
        if (!(await copyDir.exists())) await copyDir.create(recursive: true);
        copyFile = File(
          copyDir.path +
              Platform.pathSeparator +
              'passy_cli_native_messaging.json',
        );
        await copyFile.writeAsString(contents);
      } catch (_) {
        return null;
      }
      return copyFile;
    }

    Future<void> _copyManifestLinux(File file) async {
      const nativeManifestDomain = 'io.github.glitterware.passy_cli';
      const nativeManifestNewFilename = '$nativeManifestDomain.json';
      String contents;
      try {
        contents = await file.readAsString();
      } catch (_) {
        return;
      }
      String? home = Platform.environment['SNAP_REAL_HOME'];
      home ??= Platform.environment['HOME']!;
      for (String nativeManifestPath in const [
        '.mozilla/native-messaging-hosts',
        '.config/microsoft-edge/NativeMessagingHosts',
        '.config/google-chrome/NativeMessagingHosts',
        '.config/chromium/NativeMessagingHosts',
        '.config/BraveSoftware/Brave-Browser/NativeMessagingHosts',
      ]) {
        Directory nativeManifestDir =
            Directory(path_lib.join(home, nativeManifestPath));
        File nativeManifestFile = File(path_lib.join(
          nativeManifestDir.path,
          nativeManifestNewFilename,
        ));
        try {
          await nativeManifestDir.create(recursive: true);
          if (!(await nativeManifestFile.exists())) {
            await nativeManifestFile.create();
          }
          await nativeManifestFile.writeAsString(contents);
        } catch (_) {}
      }
    }

    Future<void> _copyManifestWindows(File file) async {
      const nativeManifestDomain = 'io.github.glitterware.passy_cli';
      for (String nativeManifestPath in const [
        'HKCU\\Software\\Mozilla\\NativeMessagingHosts\\',
        'HKCU\\Software\\Microsoft\\Edge\\NativeMessagingHosts\\',
        'HKCU\\Software\\Google\\Chrome\\NativeMessagingHosts\\',
        'HKCU\\Software\\BraveSoftware\\Brave-Browser\\NativeMessagingHosts\\',
      ]) {
        try {
          await Process.run('reg', [
            'add',
            '$nativeManifestPath$nativeManifestDomain',
            '/ve',
            '/t',
            'REG_SZ',
            '/d',
            file.path,
            '/f',
          ]);
        } catch (_) {}
      }
    }

    Future<bool> _testNativeMessagingHostsInterfaceAccess() async {
      const nativeManifestDomain = 'io.github.glitterware.passy_cli';
      const nativeManifestNewFilename = '$nativeManifestDomain.test';
      String? home = Platform.environment['SNAP_REAL_HOME'];
      home ??= Platform.environment['HOME']!;
      Directory? nativeManifestDir;
      for (String nativeManifestPath in const [
        '.mozilla/native-messaging-hosts',
        '.config/microsoft-edge/NativeMessagingHosts',
        '.config/google-chrome/NativeMessagingHosts',
        '.config/chromium/NativeMessagingHosts',
        '.config/BraveSoftware/Brave-Browser/NativeMessagingHosts',
      ]) {
        Directory testDir = Directory(path_lib.join(home, nativeManifestPath));
        bool exists;
        try {
          exists = await testDir.exists();
        } catch (_) {
          continue;
        }
        if (exists) {
          nativeManifestDir = testDir;
          break;
        }
      }
      if (nativeManifestDir == null) return true;
      File testManifestFile =
          File(nativeManifestDir.path + '/' + nativeManifestNewFilename);
      try {
        await testManifestFile.create();
        if (await testManifestFile.exists()) {
          await testManifestFile.delete();
          return true;
        }
      } catch (_) {}
      return false;
    }

    Future<void> _copyExtensionFiles() async {
      File? passyCliTemp = await _getTemporaryCliExecutable();
      if (passyCliTemp == null) return;
      File? manifest = await _prepareManifest(passyCliTemp.path);
      if (manifest == null) return;
      if (Platform.isLinux) {
        if (isSnap()) {
          dynamic hasAccess = await _testNativeMessagingHostsInterfaceAccess();
          if (hasAccess != true) {
            if (context.mounted) {
              showSnackBar(
                context,
                message: localizations.unableToConnectBrowserExtension,
                icon: const Icon(Icons.extension_rounded,
                    color: PassyTheme.lightContentColor),
                duration: const Duration(seconds: 10),
                action: SnackBarAction(
                  textColor: PassyTheme.lightContentColor,
                  label: localizations.details,
                  onPressed: () => openUrl(
                      'https://github.com/GlitterWare/Passy/blob/dev/SNAP-STORE.md#enabling-browser-extension-support'),
                ),
                textStyle: const TextStyle(color: PassyTheme.lightContentColor),
                backgroundColor: const Color.fromRGBO(255, 82, 82, 1),
              );
            }
            return;
          }
        }
        _copyManifestLinux(manifest);
        return;
      }
      _copyManifestWindows(manifest);
    }

    Future<void> _load() async {
      await Future.delayed(const Duration(milliseconds: 5));
      if (Platform.isWindows || Platform.isLinux) _copyExtensionFiles();
      data = await loadPassyData();
      loaded = true;
      if (data.noAccounts) {
        Navigator.pushReplacementNamed(context, AddAccountScreen.routeName);
        return;
      }
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      if (const String.fromEnvironment('UPDATES_POPUP_ENABLED') != 'false') {
        try {
          String _version = await getLatestVersion();
          if (_version == passyVersion) return;
          List<String> _newVersionSplit = _version.split('.');
          List<String> _currentVersionSplit = passyVersion.split('.');
          if (int.parse(_newVersionSplit[0]) <
              int.parse(_currentVersionSplit[0])) return;
          if (int.parse(_newVersionSplit[0]) ==
              int.parse(_currentVersionSplit[0])) {
            if (int.parse(_newVersionSplit[1]) <
                int.parse(_currentVersionSplit[1])) return;
            if (int.parse(_newVersionSplit[1]) ==
                int.parse(_currentVersionSplit[1])) {
              if (int.parse(_newVersionSplit[2]) <=
                  int.parse(_currentVersionSplit[2])) return;
            }
          }
          showUpdateDialog();
        } catch (_) {}
      }
    }

    if (!loaded) {
      _load();
    }
    return Scaffold(
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
