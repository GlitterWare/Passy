import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/autofill_splash_screen.dart';
import 'package:passy/screens/confirm_import_screen.dart';
import 'package:passy/screens/export_and_import_screen.dart';
import 'package:passy/screens/export_screen.dart';
import 'package:passy/screens/global_settings_screen.dart';
import 'package:passy/screens/import_screen.dart';
import 'package:passy/screens/no_accounts_screen.dart';

import 'common/common.dart';
import 'screens/change_password_screen.dart';
import 'screens/change_username_screen.dart';
import 'screens/confirm_restore_screen.dart';
import 'screens/credentials_screen.dart';
import 'screens/remove_account_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/security_screen.dart';
import 'screens/edit_note_screen.dart';
import 'screens/identities_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/id_cards_screen.dart';
import 'screens/backup_and_restore_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/biometric_auth_screen.dart';
import 'screens/restore_screen.dart';
import 'screens/add_account_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/edit_custom_field_screen.dart';
import 'screens/edit_id_card_screen.dart';
import 'screens/edit_identity_screen.dart';
import 'screens/edit_password_screen.dart';
import 'screens/edit_payment_card_screen.dart';
import 'screens/id_card_screen.dart';
import 'screens/identity_screen.dart';
import 'screens/log_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/note_screen.dart';
import 'screens/password_screen.dart';
import 'screens/passwords_screen.dart';
import 'screens/search_screen.dart';
import 'screens/payment_card_screen.dart';
import 'screens/payment_cards_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/unlock_screen.dart';

final ThemeData theme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: PassyTheme.theme.colorScheme,
  snackBarTheme: PassyTheme.theme.snackBarTheme,
  scaffoldBackgroundColor: PassyTheme.theme.scaffoldBackgroundColor,
  inputDecorationTheme: PassyTheme.theme.inputDecorationTheme,
  elevatedButtonTheme: PassyTheme.theme.elevatedButtonTheme,
  textSelectionTheme: PassyTheme.theme.textSelectionTheme,
);

void main() => runApp(const Passy());

@pragma('vm:entry-point')
void autofillEntryPoint() {
  runApp(MaterialApp(
    title: 'Passy',
    theme: theme,
    navigatorKey: navigatorKey,
    navigatorObservers: [
      routeObserver,
    ],
    routes: {
      AutofillSplashScreen.routeName: (context) => const AutofillSplashScreen(),
      LogScreen.routeName: (context) => const LogScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(
            autofillLogin: true,
          ),
      NoAccountsScreen.routeName: (context) => const NoAccountsScreen(),
      SearchScreen.routeName: (context) => const SearchScreen(),
      UnlockScreen.routeName: (context) => const UnlockScreen(),
    },
  ));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Passy extends StatelessWidget {
  const Passy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      AutofillService().setPreferences(AutofillPreferences(
        enableDebug: false,
        enableSaving: false,
      ));
    }
    return MaterialApp(
      title: 'Passy',
      theme: theme,
      navigatorKey: navigatorKey,
      navigatorObservers: [
        routeObserver,
      ],
      routes: {
        AddAccountScreen.routeName: (context) => const AddAccountScreen(),
        BackupAndRestoreScreen.routeName: (context) =>
            const BackupAndRestoreScreen(),
        BackupScreen.routeName: (context) => const BackupScreen(),
        BiometricAuthScreen.routeName: (context) => const BiometricAuthScreen(),
        ChangePasswordScreen.routeName: (context) =>
            const ChangePasswordScreen(),
        ChangeUsernameScreen.routeName: (context) =>
            const ChangeUsernameScreen(),
        ConfirmImportScreen.routeName: (context) => const ConfirmImportScreen(),
        ConfirmRestoreScreen.routeName: (context) =>
            const ConfirmRestoreScreen(),
        ConnectScreen.routeName: (context) => const ConnectScreen(),
        CredentialsScreen.routeName: (context) => const CredentialsScreen(),
        EditCustomFieldScreen.routeName: (context) =>
            const EditCustomFieldScreen(),
        EditIDCardScreen.routeName: (context) => const EditIDCardScreen(),
        EditIdentityScreen.routeName: (context) => const EditIdentityScreen(),
        EditNoteScreen.routeName: (context) => const EditNoteScreen(),
        EditPasswordScreen.routeName: (context) => const EditPasswordScreen(),
        EditPaymentCardScreen.routeName: (context) =>
            const EditPaymentCardScreen(),
        ExportAndImportScreen.routeName: (context) =>
            const ExportAndImportScreen(),
        ExportScreen.routeName: (context) => const ExportScreen(),
        GlobalSettingsScreen.routeName: (context) =>
            const GlobalSettingsScreen(),
        IDCardScreen.routeName: (context) => const IDCardScreen(),
        IDCardsScreen.routeName: (context) => const IDCardsScreen(),
        IdentitiesScreen.routeName: (context) => const IdentitiesScreen(),
        IdentityScreen.routeName: (context) => const IdentityScreen(),
        ImportScreen.routeName: (context) => const ImportScreen(),
        LogScreen.routeName: (context) => const LogScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        NoteScreen.routeName: (context) => const NoteScreen(),
        NotesScreen.routeName: (context) => const NotesScreen(),
        PasswordScreen.routeName: (context) => const PasswordScreen(),
        PasswordsScreen.routeName: (context) => const PasswordsScreen(),
        PaymentCardScreen.routeName: (context) => const PaymentCardScreen(),
        PaymentCardsScreen.routeName: (context) => const PaymentCardsScreen(),
        RemoveAccountScreen.routeName: (context) => const RemoveAccountScreen(),
        RestoreScreen.routeName: (context) => const RestoreScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        SecurityScreen.routeName: (context) => const SecurityScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SetupScreen.routeName: (context) => const SetupScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
        UnlockScreen.routeName: (context) => const UnlockScreen(),
      },
    );
  }
}
