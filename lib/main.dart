import 'package:flutter/material.dart';
import 'package:passy/screens/edit_id_card_screen.dart';
import 'package:passy/screens/edit_identity_screen.dart';
import 'package:passy/screens/edit_password_screen.dart';
import 'package:passy/screens/edit_payment_card_screen.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/id_card_screen.dart';
import 'package:passy/screens/identity_screen.dart';
import 'package:passy/screens/note_screen.dart';
import 'package:passy/screens/passwords_screen.dart';
import 'package:passy/screens/payment_card_screen.dart';
import 'package:passy/screens/connect_screen.dart';
import 'package:passy/screens/remove_account_screen.dart';
import 'package:passy/screens/settings_screen.dart';

import 'common/theme.dart';
import 'screens/add_account_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

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
        ConnectScreen.routeName: (context) => const ConnectScreen(),
        EditIdCardScreen.routeName: (context) => const EditIdCardScreen(),
        EditIdentityScreen.routeName: (context) => const EditIdentityScreen(),
        EditPasswordScreen.routeName: (context) => const EditPasswordScreen(),
        EditPaymentCardScreen.routeName: (context) =>
            const EditPaymentCardScreen(),
        IDCardScreen.routeName: (context) => const IDCardScreen(),
        IdentityScreen.routeName: (context) => const IdentityScreen(),
        LogScreen.routeName: (context) => const LogScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        NoteScreen.routeName: (context) => const NoteScreen(),
        PasswordsScreen.routeName: (context) => const PasswordsScreen(),
        PasswordScreen.routeName: (context) => const PasswordScreen(),
        PaymentCardScreen.routeName: (context) => const PaymentCardScreen(),
        RemoveAccountScreen.routeName: (context) => const RemoveAccountScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
      },
    );
  }
}
