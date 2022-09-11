import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'add_account_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class RemoveAccountScreen extends StatefulWidget {
  static const String routeName = '${LoginScreen.routeName}/removeAccount';

  const RemoveAccountScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoveAccountScreen();
}

class _RemoveAccountScreen extends State<RemoveAccountScreen> {
  @override
  Widget build(BuildContext context) {
    String _username = ModalRoute.of(context)!.settings.arguments as String;
    return ConfirmStringScaffold(
      title: const Text('Remove account'),
      message: PassyPadding(RichText(
        text: TextSpan(text: 'Confirm the removal of account ', children: [
          TextSpan(
            text: '\'$_username\' ',
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          ),
          const TextSpan(text: 'by typing in its username.\n\nThis action is '),
          const TextSpan(
            text: 'irreversible',
            style: TextStyle(color: PassyTheme.lightContentSecondaryColor),
          ),
          const TextSpan(text: '.'),
        ]),
        textAlign: TextAlign.center,
      )),
      labelText: 'Confirm username',
      confirmIcon: const Icon(Icons.delete_outline_rounded),
      onBackPressed: (context) => Navigator.pop(context),
      onConfirmPressed: (context, value) {
        if (value != _username) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
              content: Row(children: const [
                Icon(Icons.error_outline_rounded,
                    color: PassyTheme.darkContentColor),
                SizedBox(width: 20),
                Expanded(child: Text('Usernames do not match')),
              ]),
            ));
          return;
        }
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, SplashScreen.routeName);
        data.removeAccount(_username).then((value) {
          if (data.noAccounts) {
            Navigator.pushReplacementNamed(context, AddAccountScreen.routeName);
            return;
          }
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        });
      },
    );
  }
}
