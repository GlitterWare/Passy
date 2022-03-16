import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/common/state.dart';
import 'package:passy/passy/common.dart';
import 'package:passy/passy/passy_data.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  String _password = '';
  String _username = data.passy.lastUsername;

  List<DropdownMenuItem<String>> get usernames {
    List<DropdownMenuItem<String>> _usernames = data.usernames
        .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
              child: Text(e),
              value: e,
            ))
        .toList();
    _usernames.insert(
        0,
        DropdownMenuItem(
          child: Row(
            children: const [
              Icon(Icons.add_circle),
              Padding(
                child: Text('Add account'),
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              ),
            ],
          ),
          value: 'addAccount',
        ));
    return _usernames;
  }

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
      body: Column(
        children: [
          const Spacer(),
          Expanded(
            child: purpleLogo,
            flex: 3,
          ),
          const Spacer(),
          const Expanded(
            child: Text(
              'Log in',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _username,
                              items: usernames,
                              onChanged: (a) {
                                if (a! == 'addAccount') {
                                  setState(() {
                                    _username = data.passy.lastUsername;
                                  });
                                  Navigator.pushNamed(context, '/addAccount');
                                  return;
                                }
                                _username = a;
                              },
                              decoration: InputDecoration(
                                border: outlineInputBorder,
                                hintText: 'Username',
                              ),
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
                              decoration: InputDecoration(
                                border: outlineInputBorder,
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
    );
  }
}
