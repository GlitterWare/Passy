import 'package:passy/common/common.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/screen.dart';

import 'main_screen.dart';
import 'passwords_screen.dart';

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.notes: '',
  Screen.idCards: '',
  Screen.identities: '',
};

Future<bool> bioAuth(String username) async {
  BiometricStorageData _bioData;
  try {
    _bioData = await BiometricStorageData.fromLocker(username);
  } catch (e) {
    return false;
  }
  if (getPassyHash(_bioData.password).toString() !=
      data.getPasswordHash(username)) return false;
  data.loadAccount(username, getPassyEncrypter(_bioData.password));
  return true;
}
