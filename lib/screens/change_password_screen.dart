import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/security_screen.dart';
import 'package:passy/screens/splash_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '${SecurityScreen.routeName}/changePassword';

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
  bool _isBackupComplete = false;
  late FormattedTextParser formattedTextParser;

  void _onConfirmPressed() async {
    if (!_isBackupComplete) {
      showSnackBar(
        message: localizations.backupYourAccountBeforeProceeding,
        icon: const Icon(Icons.save_rounded),
      );
      return;
    }
    if ((await data.createPasswordHash(_account.username,
            password: _password)) !=
        data.getPasswordHash(_account.username)) {
      showSnackBar(
        message: localizations.incorrectPassword,
        icon: const Icon(Icons.lock_rounded),
      );
      return;
    }
    if (_newPassword.isEmpty) {
      showSnackBar(
        message: localizations.passwordIsEmpty,
        icon: const Icon(Icons.lock_rounded),
      );
      return;
    }
    if (_newPassword != _newPasswordConfirm) {
      showSnackBar(
        message: localizations.passwordsDoNotMatch,
        icon: const Icon(Icons.lock_rounded),
      );
      return;
    }
    Navigator.pushNamed(context, SplashScreen.routeName);
    _account.reloadHistorySync();
    _account
        .setAccountPassword(_newPassword,
            doNotReencryptEntries: _doNotReencryptEntries)
        .then((value) async {
      _account.bioAuthEnabled = false;
      await _account.saveCredentials();
      if (mounted) {
        Navigator.popUntil(context,
            (route) => route.settings.name == SecurityScreen.routeName);
      }
    });
  }

  Future<void> _onBackupPressed() async {
    try {
      String? path = await backupAccount(context,
          username: _account.username, autoFilename: false);
      if (path == null) return;
    } catch (e) {
      return;
    }
    setState(() {
      _isBackupComplete = true;
    });
  }

  @override
  void initState() {
    super.initState();
    formattedTextParser = FormattedTextParser(context: context);
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
              Text.rich(
                formattedTextParser.parse(
                  text: localizations.youAreChangingPasswordFor,
                  placeholders: {
                    'u': TextSpan(
                      text: _account.username,
                      style: TextStyle(
                        color: PassyTheme.of(context)
                            .highlightContentSecondaryColor,
                      ),
                    ),
                  },
                ),
                textAlign: TextAlign.center,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      top: PassyTheme.of(context)
                                          .passyPadding
                                          .left,
                                      bottom: PassyTheme.of(context)
                                          .passyPadding
                                          .left),
                                  child: ThreeWidgetButton(
                                      center: Text(localizations.backup),
                                      left: const Padding(
                                        padding: EdgeInsets.only(right: 30),
                                        child: Icon(Icons.save_rounded),
                                      ),
                                      right: const Icon(
                                          Icons.arrow_forward_ios_rounded),
                                      onPressed: () => _onBackupPressed()))),
                          if (_isBackupComplete)
                            const Flexible(
                                child: PassyPadding(Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 35,
                            ))),
                        ],
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
                      setState(() => _advancedSettingsIsExpanded = isExpanded),
                  elevation: 0,
                  dividerColor:
                      PassyTheme.of(context).highlightContentSecondaryColor,
                  children: [
                    ExpansionPanel(
                        backgroundColor: PassyTheme.of(context).contentColor,
                        isExpanded: _advancedSettingsIsExpanded,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(32.0)),
                                      color: PassyTheme.of(context)
                                          .accentContentColor),
                                  child: PassyPadding(Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child:
                                            Icon(Icons.error_outline_rounded),
                                      ),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                              localizations.advancedSettings)),
                                    ],
                                  ))));
                        },
                        body: Column(
                          children: [
                            PassyPadding(DropdownButtonFormField(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
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
