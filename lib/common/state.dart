import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passy/passy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account {
  int index;

  /// SHA512 encrypted password
  late String password;
  String icon;
  Color iconColor;

  Account(this.index, this.password, this.icon, this.iconColor);
}

late SharedPreferences preferences;
Completer loaded = Completer();

Map<String, Account> accounts = {};
String curUsername = '';
String curPassword = '';
late AccountData curAccountData;

Future<void> loadApp(BuildContext context) async {
  accounts.isEmpty
      ? Navigator.pushReplacementNamed(context, '/addAccount')
      : Navigator.pushReplacementNamed(context, '/login');
}
