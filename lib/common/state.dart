import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passy/passy/app_data.dart';

late AppData data;

Future<void> loadApp(BuildContext context) => data.noAccounts
    ? Navigator.pushReplacementNamed(context, '/addAccount')
    : Navigator.pushReplacementNamed(context, '/login');
