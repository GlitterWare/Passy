import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/widgets/entry_widget.dart';

import 'main_screen.dart';
import 'passwords_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/main/password';

  @override
  State<StatefulWidget> createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  Widget? _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(
      onPressed: () => Navigator.pop(context),
    );
  }

  //TODO: implement OTP display
  //TODO: implement tags
  //TODO: implement customFields

  @override
  Widget build(BuildContext context) {
    final Password _password =
        ModalRoute.of(context)!.settings.arguments as Password;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: Center(child: Text(_password.nickname)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Delete Password'),
                      content: const Text(
                          'Password can only be restored from a backup.'),
                      actions: [
                        TextButton(
                          child: const Text('No'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            _account.removePassword(_password.key);
                            Navigator.popUntil(context,
                                (r) => r.settings.name == MainScreen.routeName);
                            _account.save().whenComplete(() =>
                                Navigator.pushNamed(
                                    context, PasswordsScreen.routeName));
                          },
                        )
                      ],
                    );
                  });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              //TODO: show AddPasswordScreen
            },
          ),
        ],
      ),
      body: ListView(children: [
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Nickname',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.nickname),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Username',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.username),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Email',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.email),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Password',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.password),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Website',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.website),
            ],
          ),
        ),
        EntryWidget(
          body: Column(
            children: [
              const Text(
                'Additional Info',
                style: TextStyle(color: Colors.grey),
              ),
              Text(_password.additionalInfo),
            ],
          ),
        ),
      ]),
    );
  }
}
