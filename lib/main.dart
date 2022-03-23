import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/screens/add_id_card_screen.dart';
import 'package:passy/screens/add_identity_screen.dart';
import 'package:passy/screens/add_password_screen.dart';
import 'package:passy/screens/add_payment_card_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/id_card_screen.dart';
import 'package:passy/screens/identity_screen.dart';
import 'package:passy/screens/note_screen.dart';
import 'package:passy/screens/payment_card_screen.dart';
import 'package:passy/screens/settings_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'common/state.dart';
import 'common/theme.dart';
import 'passy/app_data.dart';
import 'screens/add_account_screen.dart';
import 'screens/start_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

const String version = '0.0.0';

void main() => runApp(const Passy());

class Passy extends StatelessWidget {
  const Passy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passy',
      theme: theme,
      routes: {
        AddAccountScreen.routeName: (context) => const AddAccountScreen(),
        AddIdCardScreen.routeName: (context) => const AddIdCardScreen(),
        AddIdentityScreen.routeName: (context) => const AddIdentityScreen(),
        AddPasswordScreen.routeName: (context) => const AddPasswordScreen(),
        AddPaymentCardScreen.routeName: (context) =>
            const AddPaymentCardScreen(),
        IDCardScreen.routeName: (context) => const IDCardScreen(),
        IdentityScreen.routeName: (context) => const IdentityScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        NoteScreen.routeName: (context) => const NoteScreen(),
        PasswordScreen.routeName: (context) => const PasswordScreen(),
        PaymentCardScreen.routeName: (context) => const PaymentCardScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
        StartScreen.routeName: (context) => const StartScreen(),
      },
    );
  }
}
