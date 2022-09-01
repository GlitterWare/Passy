import 'package:flutter/material.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/passy_data.dart';

import 'assets.dart';
import 'add_account_screen.dart';
import 'common.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      Future(() async {
        data = PassyData((await getApplicationDocumentsDirectory()).path +
            Platform.pathSeparator +
            'Passy');
        if (data.noAccounts) {
          Navigator.pushReplacementNamed(context, AddAccountScreen.routeName);
          return;
        }
        if (isBiometricStorageSupported) {
          String username = data.info.value.lastUsername;
          if (data.getBioAuthEnabled(username) ?? false) {
            BiometricStorageData _bioData;
            try {
              _bioData = await BiometricStorageData.fromLocker(
                  data.info.value.lastUsername);
            } catch (e) {
              return;
            }
            if (getPassyHash(_bioData.password).toString() ==
                data.getPasswordHash(username)) {
              LoadedAccount _account = data.loadAccount(
                  data.info.value.lastUsername,
                  getPassyEncrypter(_bioData.password));
              Navigator.pushReplacementNamed(context, MainScreen.routeName);
              if (_account.defaultScreen == Screen.main) return;
              Navigator.pushNamed(
                  context, screenToRouteName[_account.defaultScreen]!);
              return;
            }
            data.setBioAuthEnabledSync(username, true);
          }
        }

        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      });
      loaded = true;
    }
    return Scaffold(
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
