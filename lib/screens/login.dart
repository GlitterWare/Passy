import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/theme.dart';

import '../common/state.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  String _username = preferences.getString('lastLogin')!;
  String _password = '';

  Future<void> login() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Expanded(
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              color: accounts[_username]!.color,
            ),
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
                              items: accounts.keys
                                  .map<DropdownMenuItem<String>>(
                                      (e) => DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          ))
                                  .toList(),
                              onChanged: (value) => _username = value!,
                              decoration: InputDecoration(
                                border: outlineInputBorder,
                                hintText: 'Username',
                              ),
                            ),
                          )
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
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () async => {
                              login(),
                            },
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
