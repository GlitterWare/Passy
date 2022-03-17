import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passy/passy/app_data.dart';

Completer loaded = Completer();
late AppData data;

Future<void> loadApp(BuildContext context) async {
  data.noAccounts
      ? Navigator.pushReplacementNamed(context, '/addAccount')
      : Navigator.pushReplacementNamed(context, '/login');
}
