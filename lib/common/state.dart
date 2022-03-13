import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../passy/passy.dart';

Map<String, Account> accounts = {};
late SharedPreferences preferences;
Completer loaded = Completer();

Future<void> loadApp(BuildContext context) async {
  accounts.isEmpty
      ? Navigator.pushReplacementNamed(context, '/addAccount')
      : Navigator.pushReplacementNamed(context, '/signIn');
}
