import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/credentials_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName =
      '${CredentialsScreen.routeName}/changePassword';

  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordScreen();
}

class _ChangePasswordScreen extends State<ChangePasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  String _password = '';
  String _newPassword = '';
  String _newPasswordConfirm = '';
  bool _advancedSettingsIsExpanded = false;
  bool _doNotReencryptEntries = false;

  void _onConfirmPressed() {
    if (getPassyHash(_password).toString() !=
        data.getPasswordHash(_account.username)) {
      showSnackBar(context,
          message: localizations.incorrectPassword,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    if (_newPassword.isEmpty) {
      showSnackBar(context,
          message: localizations.passwordIsEmpty,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      showSnackBar(context,
          message: localizations.passwordsDoNotMatch,
          icon: const Icon(
            Icons.lock_rounded,
            color: PassyTheme.darkContentColor,
          ));
      return;
    }
    Navigator.pushNamed(context, SplashScreen.routeName);
    _account.reloadHistorySync();
    _account
        .setAccountPassword(_newPassword,
            doNotReencryptEntries: _doNotReencryptEntries)
        .then((value) {
      Navigator.popUntil(context,
          (route) => route.settings.name == CredentialsScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.changePassword),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                    text: localizations.youAreChangingPasswordFor,
                    children: [
                      TextSpan(
                        text: _account.username,
                        style: const TextStyle(
                          color: PassyTheme.lightContentSecondaryColor,
                        ),
                      ),
                      const TextSpan(text: '.')
                    ]),
              ),
              Expanded(
                child: PassyPadding(
                  Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: localizations.currentPassword),
                        obscureText: true,
                        onChanged: (s) => setState(() => _password = s),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: localizations.newPassword),
                        obscureText: true,
                        onChanged: (s) => setState(() => _newPassword = s),
                      ),
                      ButtonedTextFormField(
                        labelText: localizations.confirmPassword,
                        obscureText: true,
                        onChanged: (s) =>
                            setState(() => _newPasswordConfirm = s),
                        onFieldSubmitted: (s) => _onConfirmPressed(),
                        onPressed: _onConfirmPressed,
                        buttonIcon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              ExpansionPanelList(
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (panelIndex, isExpanded) =>
                      setState(() => _advancedSettingsIsExpanded = !isExpanded),
                  elevation: 0,
                  dividerColor: PassyTheme.lightContentSecondaryColor,
                  children: [
                    ExpansionPanel(
                        backgroundColor: PassyTheme.darkContentColor,
                        isExpanded: _advancedSettingsIsExpanded,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(32.0)),
                                      color: PassyTheme.darkPassyPurple),
                                  child: const PassyPadding(Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child:
                                            Icon(Icons.error_outline_rounded),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          //TODO: Move 'Advanced settings' to localizations
                                          child: Text('Advanced settings')),
                                    ],
                                  ))));
                        },
                        body: Column(
                          children: [
                            PassyPadding(DropdownButtonFormField(
                              items: [
                                DropdownMenuItem(
                                  child: Text(localizations.true_),
                                  value: true,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                      '${localizations.false_} (${localizations.recommended.toLowerCase()})'),
                                  value: false,
                                ),
                              ],
                              value: _doNotReencryptEntries,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Disable entry re-encryption (Maintenance use only)'),
                              onChanged: (value) => setState(
                                  () => _doNotReencryptEntries = value as bool),
                            )),
                          ],
                        ))
                  ]),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
