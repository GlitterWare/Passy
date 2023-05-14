import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path_lib;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/add_account_screen.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/screens/common.dart';
import 'package:path_provider/path_provider.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    loadLocalizations(context);
    Future<void> showUpdateDialog() {
      return showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: PassyTheme.dialogShape,
          title: const Text('New version available'),
          content: ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SvgPicture.asset(
                'assets/images/github_icon.svg',
                width: 26,
                color: PassyTheme.lightContentColor,
              ),
            ),
            center: const Text('Download'),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () =>
                openUrl('https://github.com/GlitterWare/Passy/releases/latest'),
          ),
        ),
      );
    }

    Future<File?> _getTemporaryCliExecutable() async {
      //TODO: create and return script instead of executable
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
            (await getApplicationDocumentsDirectory()).path +
                Platform.pathSeparator +
                'Passy' +
                Platform.pathSeparator +
                'passy_cli' +
                Platform.pathSeparator +
                'temp' +
                Platform.pathSeparator +
                'bin' +
                Platform.pathSeparator +
                'passy_cli');
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
        String date = DateTime.now().toIso8601String().replaceAll(':', ';');
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
          (await getApplicationDocumentsDirectory()).path +
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
      for (String nativeManifestPath in const [
        '.mozilla/native-messaging-hosts',
        '.config/microsoft-edge/NativeMessagingHosts',
        '.config/google-chrome/NativeMessagingHosts',
        '.config/chromium/NativeMessagingHosts',
        '.config/BraveSoftware/Brave-Browser/NativeMessagingHosts',
      ]) {
        Directory nativeManifestDir = Directory(path_lib.join(
          'home',
          Platform.environment['HOME'],
          nativeManifestPath,
        ));
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
        'HKCU\\Software\\Microsoft\\Edge\\NativeMessagingHosts',
        'HKCU\\Software\\Google\\Chrome\\NativeMessagingHosts\\',
        'HKCU\\Software\\BraveSoftware\\Brave\\NativeMessagingHosts\\',
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

    Future<void> _copyExtensionFiles() async {
      File? passyCliTemp = await _getTemporaryCliExecutable();
      if (passyCliTemp == null) return;
      File? manifest = await _prepareManifest(passyCliTemp.path);
      if (manifest == null) return;
      if (Platform.isLinux) {
        _copyManifestLinux(manifest);
        return;
      }
      _copyManifestWindows(manifest);
    }

    Future<void> _load() async {
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
