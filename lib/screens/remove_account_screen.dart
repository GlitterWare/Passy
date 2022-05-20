import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/widgets/back_button.dart';
import 'package:passy/widgets/text_form_field_buttoned.dart';

class RemoveAccountScreen extends StatefulWidget {
  const RemoveAccountScreen({Key? key}) : super(key: key);

  static const routeName = '/login/removeAccount';

  @override
  State<StatefulWidget> createState() => _RemoveAccountScreen();
}

class _RemoveAccountScreen extends State<RemoveAccountScreen> {
  @override
  Widget build(BuildContext context) {
    String _confirmation = '';
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;

    void _removeAccount() {
      if (_confirmation != _username) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.error_outline_rounded, color: darkContentColor),
              const SizedBox(width: 20),
              const Expanded(child: Text('Usernames do not match')),
            ]),
          ));
        return;
      }
      Navigator.pushReplacementNamed(context, SplashScreen.routeName);
      data.removeAccount(_username).then((value) =>
          Navigator.pushReplacementNamed(context, LoginScreen.routeName));
    }

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, LoginScreen.routeName),
        ),
        title: const Text('Remove account'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(children: [
              const Spacer(),
              Padding(
                padding: entryPadding,
                child: RichText(
                  text: TextSpan(
                      text: 'Confirm the removal of account ',
                      children: [
                        TextSpan(
                          text: '\'$_username\' ',
                          style: TextStyle(color: lightContentSecondaryColor),
                        ),
                        const TextSpan(text: 'by typing in its username.'),
                      ]),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: entryPadding,
                child: RichText(
                  text: TextSpan(text: 'This action is ', children: [
                    TextSpan(
                      text: 'irreversible',
                      style: TextStyle(color: lightContentSecondaryColor),
                    ),
                    const TextSpan(text: '.'),
                  ]),
                  textAlign: TextAlign.center,
                ),
              ),
              TextFormFieldButtoned(
                labelText: 'Confirm username',
                onChanged: (s) => _confirmation = s,
                onPressed: _removeAccount,
                buttonIcon: const Icon(Icons.delete_outline_rounded),
              ),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
