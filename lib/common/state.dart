import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passy/passy/passy_data.dart';

Completer loaded = Completer();
late PassyData data;

Future<void> loadApp(BuildContext context) async {
  data.noAccounts
      ? Navigator.pushReplacementNamed(context, '/addAccount')
      : Navigator.pushReplacementNamed(context, '/login');
}
