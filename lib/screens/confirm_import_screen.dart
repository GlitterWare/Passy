import 'dart:io';

import 'package:encrypt/encrypt.dart' as crypt;
import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';

import 'import_screen.dart';
import 'log_screen.dart';

enum ImportType {
  passy,
  kdbx,
  aegis,
}

class ConfirmImportScreenArgs {
  final String path;
  final ImportType importType;

  ConfirmImportScreenArgs({
    required this.path,
    required this.importType,
  });
}

class ConfirmImportScreen extends StatefulWidget {
  static const String routeName = '${ImportScreen.routeName}/confirm';

  const ConfirmImportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmImportScreen();
}

class _ConfirmImportScreen extends State<ConfirmImportScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  Future<void> _onConfirmPressed(
      BuildContext context, String value, ConfirmImportScreenArgs args) async {
    Navigator.pushNamed(context, SplashScreen.routeName);
    try {
      switch (args.importType) {
        case ImportType.passy:
          crypt.Key key =
              (await data.derivePassword(_account.username, password: value))!;
          await data.importAccount(args.path,
              encrypter: getPassyEncrypterFromBytes(key.bytes),
              key: key,
              encryptedPassword: encrypt(value,
                  encrypter:
                      crypt.Encrypter(crypt.AES(crypt.Key.fromUtf8(value)))));
          Navigator.popUntil(
              context, (route) => route.settings.name == MainScreen.routeName);
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          showSnackBar(
            message: localizations.imported,
            icon: const Icon(Icons.check, color: PassyTheme.darkContentColor),
          );
          break;
        case ImportType.kdbx:
          KdbxFile file = await KdbxFormat().read(
              await File(args.path).readAsBytes(),
              Credentials(ProtectedValue.fromString(value)));
          await _account
              .importKDBXPasswords(file.body.rootGroup.getAllEntries());
          Navigator.popUntil(context,
              (route) => route.settings.name == ImportScreen.routeName);
          showSnackBar(
            message: localizations.imported,
            icon: const Icon(Icons.check, color: PassyTheme.darkContentColor),
          );
          break;
        case ImportType.aegis:
          File file = File(args.path);
          await _account.importAegis(
              aegisFile: file, password: value.isEmpty ? null : value);
          Navigator.popUntil(context,
              (route) => route.settings.name == ImportScreen.routeName);
          showSnackBar(
            message: localizations.imported,
            icon: const Icon(Icons.check, color: PassyTheme.darkContentColor),
          );
          break;
      }
    } catch (e, s) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      Navigator.pop(context);
      if (e.runtimeType.toString() == 'InvalidCipherTextException') {
        showSnackBar(
          message: localizations.incorrectPassword,
          icon: const Icon(Icons.download_for_offline_outlined,
              color: PassyTheme.darkContentColor),
          action: SnackBarAction(
            label: localizations.details,
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: e.toString() + '\n' + s.toString()),
          ),
        );
        return;
      }
      showSnackBar(
        message: localizations.couldNotImportAccount,
        icon: const Icon(Icons.download_for_offline_outlined,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfirmImportScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as ConfirmImportScreenArgs;
    String title;
    switch (args.importType) {
      case ImportType.passy:
        title = localizations.passyImport;
        break;
      case ImportType.kdbx:
        title = localizations.kdbxImport;
        break;
      case ImportType.aegis:
        title = localizations.aegisImport;
        break;
    }
    return ConfirmStringScaffold(
        title: Text(title),
        message: PassyPadding(Text.rich(
          TextSpan(
            text: localizations.confirmImport1,
            children: [
              TextSpan(
                text: localizations.confirmImport2Highlighted,
                style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor),
              ),
              TextSpan(
                  text:
                      '${localizations.confirmImport3}.\n\n${localizations.enterAccountPasswordToImport}.'),
            ],
          ),
          textAlign: TextAlign.center,
        )),
        labelText: localizations.enterPassword,
        obscureText: true,
        confirmIcon: const Icon(Icons.download_for_offline_outlined),
        onBackPressed: (context) => Navigator.pop(context),
        onConfirmPressed: (context, value) =>
            _onConfirmPressed(context, value, args));
  }
}
