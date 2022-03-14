import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, String> passwords = {};
late SharedPreferences preferences;
Completer loaded = Completer();

Future<void> loadApp(BuildContext context) async {
  passwords.isEmpty
      ? Navigator.pushReplacementNamed(context, '/addAccount')
      : Navigator.pushReplacementNamed(context, '/login');
}
