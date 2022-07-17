import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/assets.dart';
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

CachedNetworkImage getFavIcon(String website) {
  if (!website.contains(RegExp(r'https://|http://'))) {
    website = 'http://$website';
  }
  String _request =
      'https://s2.googleusercontent.com/s2/favicons?sz=32&domain=$website';
  CachedNetworkImage _image = CachedNetworkImage(
    imageUrl: _request,
    placeholder: (context, url) => logoCircle50White,
    errorWidget: (ctx, obj, s) => logoCircle50White,
    width: 50,
    fit: BoxFit.fill,
  );
  return _image;
}

Widget buildPasswordWidget(
    {required BuildContext context,
    required LoadedAccount account,
    required Password password}) {
  return ThreeWidgetButton(
    left: password.website == ''
        ? logoCircle50White
        : getFavIcon(password.website),
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
