import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  String _password = '';
  String _username = data.passy.lastUsername;

  List<DropdownMenuItem<String>> usernames = data.usernames
      .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
            child: Text(e),
            value: e,
          ))
      .toList();

  void login(BuildContext context) {
    if (getPasswordHash(_password) ==
        data.getPasswordHash(data.passy.lastUsername)) {
      Navigator.pushReplacementNamed(context, '/splash');
      Future(() {
        data.passy.lastUsername = _username;
        data.passy.saveSync();
        data.loadAccount(data.passy.lastUsername, _password);
        Navigator.pushReplacementNamed(context, '/main');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                purpleLogo,
                const Spacer(),
                const Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
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
                                FloatingActionButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/addAccount'),
                                  child: const Icon(Icons.add_rounded),
                                  heroTag: 'addAccountBtn',
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _username,
                                    items: usernames,
                                    onChanged: (a) {
                                      if (a! == 'addAccount') {
                                        Navigator.pushNamed(
                                            context, '/addAccount');
                                        return;
                                      }
                                      _username = a;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    onChanged: (a) => _password = a,
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(' '),
                                      LengthLimitingTextInputFormatter(32),
                                    ],
                                    autofocus: true,
                                  ),
                                ),
                                FloatingActionButton(
                                  onPressed: () => login(context),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                  ),
                                  heroTag: 'loginBtn',
                                ),
                              ],
                            ),
                            const Spacer(flex: 2),
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
