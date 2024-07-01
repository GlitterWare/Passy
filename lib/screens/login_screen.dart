import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';
import 'package:passy/passy_data/bio_starge.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/key_derivation_info.dart';
import 'package:passy/passy_data/key_derivation_type.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_search.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/screens/remove_account_screen.dart';
import 'package:passy/screens/search_screen.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'add_account_screen.dart';
import 'common.dart';
import 'edit_password_screen.dart';
import 'global_settings_screen.dart';
import 'main_screen.dart';
import 'log_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  static bool didRun = false;
  Widget? _floatingActionButton;
  String _password = '';
  String _username = data.info.value.lastUsername;
  FloatingActionButton? _bioAuthButton;
  final TextEditingController _passwordController = TextEditingController();
  bool isCapsLockEnabled = false;

  Future<void> _bioAuth() async {
    if (Platform.isAndroid || Platform.isIOS) {
      UnlockScreen.isAuthenticating = true;
      if (data.getBioAuthEnabled(_username) ?? false) {
        BiometricStorageData storageData =
            await BioStorage.fromLocker(_username);
        KeyDerivationType derivationType =
            data.getKeyDerivationType(_username)!;
        KeyDerivationInfo? derivationInfo =
            data.getKeyDerivationInfo(_username);
        if (data.getPasswordHash(_username) ==
            (await getPasswordHash(storageData.password,
                    derivationType: derivationType,
                    derivationInfo: derivationInfo))
                .toString()) {
          Navigator.popUntil(
              context, (route) => route.settings.name == LoginScreen.routeName);
          Navigator.pushNamed(context, SplashScreen.routeName);
          if (data.info.value.lastUsername != _username) {
            data.info.value.lastUsername = _username;
            await data.info.save();
          }
          enc.Key key = await derivePassword(storageData.password,
              derivationType: derivationType, derivationInfo: derivationInfo);
          enc.Encrypter encrypter = getPassyEncrypterFromBytes(key.bytes);
          LoadedAccount account = await data.loadAccount(
              _username, encrypter, key,
              encryptedPassword:
                  encrypt(storageData.password, encrypter: encrypter));
          Navigator.pop(context);
          if (isAutofill) {
            Navigator.pushNamed(
              context,
              SearchScreen.routeName,
              arguments: SearchScreenArgs(
                entryType: null,
                builder: _buildPasswords,
                isAutofill: true,
              ),
            );
            return;
          }
          account.startAutoSync();
          Navigator.pushReplacementNamed(context, MainScreen.routeName);
        }
      }
      Future.delayed(const Duration(seconds: 2))
          .then((value) => UnlockScreen.isAuthenticating = false);
    }
  }

  Widget _buildPasswords(
      String terms, List<String> tags, void Function() rebuild) {
    List<PasswordMeta> _found = PassySearch.searchPasswords(
        passwords: data.loadedAccount!.passwordsMetadata.values,
        terms: terms,
        tags: tags);
    List<PwDataset> _dataSets = [];
    return PasswordButtonListView(
      topWidgets: [
        PassyPadding(ThreeWidgetButton(
          left: const Icon(Icons.add_rounded),
          center: Text(
            localizations.addPassword,
            textAlign: TextAlign.center,
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () =>
              Navigator.pushNamed(context, EditPasswordScreen.routeName),
        )),
      ],
      passwords: _found,
      onPressed: (passwordMeta) async {
        PasswordMeta password = PasswordMeta(
            key: passwordMeta.key,
            tags: passwordMeta.tags,
            nickname: '>>> ${passwordMeta.nickname} <<<<',
            username: passwordMeta.username,
            websites: passwordMeta.websites);
        _found.remove(password);
        _found.insert(0, password);
        int max = _found.length < 5 ? _found.length : 5;
        for (int i = 0; i != max; i++) {
          PasswordMeta _password = _found[i];
          Password? _pass = data.loadedAccount!.getPassword(_password.key);
          if (_pass == null) continue;
          _dataSets.add(PwDataset(
            label: _password.nickname,
            username: _pass.username.isNotEmpty ? _pass.username : _pass.email,
            password: _pass.password,
          ));
        }
        await AutofillService().resultWithDatasets(_dataSets);
        Navigator.pop(context);
      },
      shouldSort: true,
    );
  }

  void login() async {
    List<int>? _derivedPassword;
    bool _isPasswordWrong = false;
    switch (data.getKeyDerivationType(_username)) {
      case KeyDerivationType.none:
        if (getPassyHash(_password).toString() !=
            data.getPasswordHash(_username)) {
          _isPasswordWrong = true;
        }
        break;
      case KeyDerivationType.argon2:
        try {
          _derivedPassword =
              (await data.getArgon2Key(_username, password: _password))!
                  .rawBytes;
        } catch (e, s) {
          showSnackBar(
            message: localizations.couldNotLogin,
            icon: const Icon(Icons.lock_rounded,
                color: PassyTheme.darkContentColor),
            action: SnackBarAction(
              label: localizations.details,
              onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                  arguments: e.toString() + '\n' + s.toString()),
            ),
          );
          _isPasswordWrong = true;
          break;
        }
        if (sha512.convert(_derivedPassword).toString() !=
            data.getPasswordHash(_username)) {
          _isPasswordWrong = true;
        }
        break;
      default:
        _isPasswordWrong = true;
        break;
    }
    if (_isPasswordWrong) {
      showSnackBar(
        message: localizations.incorrectPassword,
        icon:
            const Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
      );
      setState(() {
        _password = '';
        _passwordController.text = '';
      });
      return;
    }
    Navigator.pushNamed(context, SplashScreen.routeName);
    if (data.info.value.lastUsername != _username) {
      data.info.value.lastUsername = _username;
      await data.info.save();
    }
    try {
      enc.Key key = _derivedPassword == null
          ? enc.Key.fromUtf8(
              _password + (' ' * (32 - utf8.encode(_password).length)))
          : enc.Key(Uint8List.fromList(_derivedPassword));
      LoadedAccount _account = await data.loadAccount(
          data.info.value.lastUsername,
          _derivedPassword == null
              ? getPassyEncrypter(_password)
              : getPassyEncrypterFromBytes(
                  Uint8List.fromList(_derivedPassword)),
          key,
          encryptedPassword:
              encrypt(_password, encrypter: enc.Encrypter(enc.AES(key))));
      Navigator.pop(context);
      if (isAutofill) {
        Navigator.pushNamed(
          context,
          SearchScreen.routeName,
          arguments: SearchScreenArgs(
            entryType: null,
            builder: _buildPasswords,
            isAutofill: true,
          ),
        );
        return;
      }
      _account.startAutoSync();
      if (Platform.isAndroid) {
        FlutterSecureScreen.singleton
            .setAndroidScreenSecure(_account.protectScreen);
      }
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    } catch (e, s) {
      showSnackBar(
        message: localizations.couldNotLogin,
        icon:
            const Icon(Icons.lock_rounded, color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    }
  }

  void updateBioAuthButton() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (data.getBioAuthEnabled(_username) == true) {
      _bioAuthButton = FloatingActionButton(
        onPressed: () => _bioAuth(),
        child: const Icon(Icons.fingerprint_rounded),
        tooltip: localizations.authenticate,
        heroTag: null,
      );
      return;
    }
    _bioAuthButton = null;
  }

  @override
  void initState() {
    super.initState();
    data.refreshAccounts();
    if (!isAutofill) {
      if (Platform.isAndroid) {
        FlutterSecureScreen.singleton.setAndroidScreenSecure(true);
      }
      _floatingActionButton =
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton(
          foregroundColor: PassyTheme.lightContentColor,
          backgroundColor: Colors.purple,
          child: const Icon(Icons.settings_rounded),
          tooltip: localizations.settings,
          heroTag: null,
          onPressed: () =>
              Navigator.pushNamed(context, GlobalSettingsScreen.routeName),
        ),
        if (!Platform.isAndroid && !Platform.isIOS)
          Padding(
            padding: EdgeInsets.only(left: PassyTheme.passyPadding.left),
            child: FloatingActionButton(
              foregroundColor: PassyTheme.lightContentColor,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.extension_rounded),
              tooltip: localizations.passyBrowserExtension,
              heroTag: null,
              onPressed: () => openUrl(
                  'https://github.com/GlitterWare/Passy-Browser-Extension/blob/main/DOWNLOADS.md'),
            ),
          ),
      ]);
    }
    if (didRun) return;
    didRun = true;
    _bioAuth();
  }

  @override
  Widget build(BuildContext context) {
    updateBioAuthButton();
    List<String> usernamesSorted = data.usernames.toList();
    usernamesSorted.sort((a, b) => alphabeticalCompare(a, b));
    final List<DropdownMenuItem<String>> usernames = usernamesSorted
        .map<DropdownMenuItem<String>>((_username) => DropdownMenuItem(
              child: Row(children: [
                Expanded(child: Text(_username)),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      RemoveAccountScreen.routeName,
                      arguments: _username,
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: localizations.remove,
                  splashRadius: PassyTheme.appBarButtonSplashRadius,
                  padding: PassyTheme.appBarButtonPadding,
                ),
              ]),
              value: _username,
            ))
        .toList();

    return Scaffold(
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(flex: 2),
                logo60Purple,
                const Spacer(),
                Expanded(
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (!isAutofill)
                                  FloatingActionButton(
                                    foregroundColor:
                                        PassyTheme.lightContentColor,
                                    backgroundColor: Colors.purple,
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(context,
                                            AddAccountScreen.routeName),
                                    child: const Icon(Icons.add_rounded),
                                    tooltip: localizations.addAccount,
                                    heroTag: 'addAccountBtn',
                                  ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isDense: false,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    value: _username,
                                    items: usernames,
                                    selectedItemBuilder: (context) {
                                      return usernames.map<Widget>((item) {
                                        return Text(item.value!);
                                      }).toList();
                                    },
                                    onChanged: (a) {
                                      setState(() => _username = a!);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (isCapsLockEnabled)
                                  const PassyPadding(Icon(
                                    Icons.arrow_upward_rounded,
                                    color: Color.fromRGBO(255, 82, 82, 1),
                                  )),
                                Expanded(
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    onChanged: (a) => setState(() {
                                      if (HardwareKeyboard
                                          .instance.lockModesEnabled
                                          .contains(
                                              KeyboardLockMode.capsLock)) {
                                        isCapsLockEnabled = true;
                                      } else {
                                        isCapsLockEnabled = false;
                                      }
                                      _password = a;
                                    }),
                                    onSubmitted: (s) => login(),
                                    decoration: InputDecoration(
                                      hintText: localizations.password,
                                    ),
                                    autofocus: true,
                                  ),
                                ),
                                FloatingActionButton(
                                  onPressed: () => login(),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                  ),
                                  tooltip: localizations.logIn,
                                  heroTag: null,
                                ),
                                if (_bioAuthButton != null) _bioAuthButton!,
                              ],
                            ),
                          ],
                        ),
                        flex: 10,
                      ),
                      const Spacer(),
                    ],
                  ),
                  flex: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
