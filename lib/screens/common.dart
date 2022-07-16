import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/widgets/three_widget_button.dart';

void sortPasswords(List<Password> passwords) {
  passwords.sort((a, b) {
    int _nickComp = a.nickname.compareTo(b.nickname);
    if (_nickComp == 0) {
      return a.username.compareTo(b.username);
    }
    return _nickComp;
  });
}

Widget getPasswordIcon(
    {required LoadedAccount account, required String iconName}) {
  Uint8List? _icon = account.getPasswordIcon(iconName)?.value;
  if (_icon == null) {
    return SvgPicture.asset(
      logoCircleSvg,
      width: 50,
      color: lightContentColor,
    );
  }
  return Image.memory(_icon);
}

Widget buildPasswordWidget(
    {required BuildContext context,
    required LoadedAccount account,
    required Password password}) {
  return ThreeWidgetButton(
    left: getPasswordIcon(account: account, iconName: password.iconName),
    right: const Icon(Icons.arrow_forward_ios_rounded),
    onPressed: () {
      Navigator.pushNamed(context, PasswordScreen.routeName,
          arguments: password);
    },
    center: Column(
      children: [
        Align(
          child: Text(
            password.nickname,
          ),
          alignment: Alignment.centerLeft,
        ),
        Align(
          child: Text(
            password.username,
            style: const TextStyle(color: Colors.grey),
          ),
          alignment: Alignment.centerLeft,
        ),
      ],
    ),
  );
}

List<Widget> buildPasswordWidgets({
  required BuildContext context,
  required LoadedAccount account,
  List<Password>? passwords,
}) {
  final List<Widget> _passwordWidgets = [];
  if (passwords == null) {
    passwords = account.passwords.toList();
    sortPasswords(passwords);
  }
  for (Password password in passwords) {
    _passwordWidgets.add(buildPasswordWidget(
        context: context, account: account, password: password));
  }
  return _passwordWidgets;
}
