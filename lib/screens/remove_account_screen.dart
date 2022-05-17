import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/widgets/back_button.dart';

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
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, SplashScreen.routeName);
      data.removeAccount(_username).then((value) =>
          Navigator.pushReplacementNamed(context, LoginScreen.routeName));
    }

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Remove account'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(children: [
              const Spacer(),
              RichText(
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
              RichText(
                text: TextSpan(text: 'This action is ', children: [
                  TextSpan(
                    text: 'irreversible',
                    style: TextStyle(color: lightContentSecondaryColor),
                  ),
                  const TextSpan(text: '.'),
                ]),
                textAlign: TextAlign.center,
              ),
              Row(children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: entryPadding.right,
                        top: entryPadding.top,
                        bottom: entryPadding.bottom),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Confirm username',
                      ),
                      onChanged: (s) => _confirmation = s,
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(right: entryPadding.right),
                    child: FloatingActionButton(
                      onPressed: _removeAccount,
                      child: const Icon(Icons.delete_outline_rounded),
                      heroTag: 'addAccountBtn',
                    ),
                  ),
                )
              ]),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
