import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/passwords_screen.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '${PasswordsScreen.routeName}/editPassword';

  @override
  State<StatefulWidget> createState() => _EditPasswordScreen();
}

class _EditPasswordScreen extends State<EditPasswordScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    Object? _args = ModalRoute.of(context)!.settings.arguments;
    bool _isNew = _args == null;
    final Password _password = _isNew ? Password() : _args as Password;

    _args = null;

    return Scaffold(
      appBar: getEditScreenAppBar(
        context,
        title: 'Password',
        isNew: _isNew,
        onSave: () {
          _account.setPassword(_password);
          Navigator.popUntil(
              context, (r) => r.settings.name == MainScreen.routeName);
          _account.save().whenComplete(
              () => Navigator.pushNamed(context, PasswordsScreen.routeName));
        },
      ),
      body: ListView(children: [
        TextFormField(
          initialValue: _password.nickname,
          decoration: const InputDecoration(labelText: 'Nickname'),
          onChanged: (value) => _password.nickname = value,
        ),
        TextFormField(
          initialValue: _password.username,
          decoration: const InputDecoration(labelText: 'Username'),
          onChanged: (value) => _password.username = value,
        ),
        TextFormField(
          initialValue: _password.password,
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (value) => _password.password = value,
        ),
        TextFormField(
          initialValue: _password.tfaSecret,
          decoration: const InputDecoration(labelText: '2FA Secret'),
          onChanged: (value) => _password.tfaSecret = value,
        ),
        TextFormField(
          initialValue: _password.website,
          decoration: const InputDecoration(labelText: 'Website'),
          onChanged: (value) => _password.website = value,
        ),
        TextFormField(
          initialValue: _password.additionalInfo,
          decoration: const InputDecoration(labelText: 'Additional'),
          onChanged: (value) => _password.additionalInfo = value,
        ),
      ]),
    );
  }
}
