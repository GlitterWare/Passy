import 'dart:io';

import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kdbx/kdbx.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/add_file_screen.dart';
import 'package:passy/screens/autofill_splash_screen.dart';
import 'package:passy/screens/automatic_backup_screen.dart';
import 'package:passy/screens/confirm_import_screen.dart';
import 'package:passy/screens/confirm_kdbx_export_screen.dart';
import 'package:passy/screens/export_and_import_screen.dart';
import 'package:passy/screens/export_screen.dart';
import 'package:passy/screens/passy_file_screen.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/global_settings_screen.dart';
import 'package:passy/screens/import_screen.dart';
import 'package:passy/screens/key_derivation_screen.dart';
import 'package:passy/screens/manage_servers_screen.dart';
import 'package:passy/screens/no_accounts_screen.dart';
import 'package:passy/screens/server_connect_screen.dart';
import 'package:passy/screens/servers_screen.dart';

import 'common/common.dart';
import 'screens/change_password_screen.dart';
import 'screens/change_username_screen.dart';
import 'screens/common.dart';
import 'screens/confirm_restore_screen.dart';
import 'screens/credentials_screen.dart';
import 'screens/csv_import_screen.dart';
import 'screens/csv_import_entries_screen.dart';
import 'screens/remove_account_screen.dart';
import 'screens/server_setup_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/security_screen.dart';
import 'screens/edit_note_screen.dart';
import 'screens/identities_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/id_cards_screen.dart';
import 'screens/backup_and_restore_screen.dart';
import 'screens/biometric_auth_screen.dart';
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
import 'screens/synchronization_logs_screen.dart';
import 'screens/unlock_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final ThemeData theme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: PassyTheme.theme.colorScheme,
  snackBarTheme: PassyTheme.theme.snackBarTheme,
  scaffoldBackgroundColor: PassyTheme.theme.scaffoldBackgroundColor,
  inputDecorationTheme: PassyTheme.theme.inputDecorationTheme,
  elevatedButtonTheme: PassyTheme.theme.elevatedButtonTheme,
  textSelectionTheme: PassyTheme.theme.textSelectionTheme,
  floatingActionButtonTheme: PassyTheme.theme.floatingActionButtonTheme,
);

void main() {
  KdbxDargon2().initialize(KdbxDargon2Platform.flutter);
  DArgon2Flutter.init();
  runApp(const Passy());
}

@pragma('vm:entry-point')
void autofillEntryPoint() {
  isAutofill = true;
  runApp(MaterialApp(
    title: 'Passy',
    theme: theme,
    navigatorKey: navigatorKey,
    navigatorObservers: [
      routeObserver,
    ],
    routes: {
      AutofillSplashScreen.routeName: (context) => const AutofillSplashScreen(),
      EditPasswordScreen.routeName: (context) => const EditPasswordScreen(),
      LogScreen.routeName: (context) => const LogScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      NoAccountsScreen.routeName: (context) => const NoAccountsScreen(),
      SearchScreen.routeName: (context) => const SearchScreen(),
      UnlockScreen.routeName: (context) => const UnlockScreen(),
    },
    localizationsDelegates: const [
      AppLocalizations.delegate, // Add this line
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    // LOCALIZATION TEST
    //locale: const Locale('it'),
    supportedLocales: supportedLocales,
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
        AddFileScreen.routeName: (context) => const AddFileScreen(),
        AutomaticBackupScreen.routeName: (context) =>
            const AutomaticBackupScreen(),
        BackupAndRestoreScreen.routeName: (context) =>
            const BackupAndRestoreScreen(),
        BiometricAuthScreen.routeName: (context) => const BiometricAuthScreen(),
        ChangePasswordScreen.routeName: (context) =>
            const ChangePasswordScreen(),
        ChangeUsernameScreen.routeName: (context) =>
            const ChangeUsernameScreen(),
        ConfirmImportScreen.routeName: (context) => const ConfirmImportScreen(),
        ConfirmKdbxExportScreen.routeName: (context) =>
            const ConfirmKdbxExportScreen(),
        ConfirmRestoreScreen.routeName: (context) =>
            const ConfirmRestoreScreen(),
        ConnectScreen.routeName: (context) => const ConnectScreen(),
        CredentialsScreen.routeName: (context) => const CredentialsScreen(),
        CSVImportScreen.routeName: (context) => const CSVImportScreen(),
        CSVImportEntriesScreen.routeName: (context) =>
            const CSVImportEntriesScreen(),
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
        FilesScreen.routeName: (context) => const FilesScreen(),
        PassyFileScreen.routeName: (context) => const PassyFileScreen(),
        GlobalSettingsScreen.routeName: (context) =>
            const GlobalSettingsScreen(),
        IDCardScreen.routeName: (context) => const IDCardScreen(),
        IDCardsScreen.routeName: (context) => const IDCardsScreen(),
        IdentitiesScreen.routeName: (context) => const IdentitiesScreen(),
        IdentityScreen.routeName: (context) => const IdentityScreen(),
        ImportScreen.routeName: (context) => const ImportScreen(),
        KeyDerivationScreen.routeName: (context) => const KeyDerivationScreen(),
        LogScreen.routeName: (context) => const LogScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        ManageServersScreen.routeName: (context) => const ManageServersScreen(),
        NoteScreen.routeName: (context) => const NoteScreen(),
        NotesScreen.routeName: (context) => const NotesScreen(),
        PasswordScreen.routeName: (context) => const PasswordScreen(),
        PasswordsScreen.routeName: (context) => const PasswordsScreen(),
        PaymentCardScreen.routeName: (context) => const PaymentCardScreen(),
        PaymentCardsScreen.routeName: (context) => const PaymentCardsScreen(),
        RemoveAccountScreen.routeName: (context) => const RemoveAccountScreen(),
        SearchScreen.routeName: (context) => const SearchScreen(),
        SecurityScreen.routeName: (context) => const SecurityScreen(),
        ServerConnectScreen.routeName: (context) => const ServerConnectScreen(),
        ServerSetupScreen.routeName: (context) => const ServerSetupScreen(),
        ServersScreen.routeName: (context) => const ServersScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        SetupScreen.routeName: (context) => const SetupScreen(),
        SplashScreen.routeName: (context) => const SplashScreen(),
        SynchronizationLogsScreen.routeName: (context) =>
            const SynchronizationLogsScreen(),
        UnlockScreen.routeName: (context) => const UnlockScreen(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => FutureBuilder(
                    future: Future<String>(() async {
                      while (SplashScreen.loaded != true) {
                        await Future.delayed(const Duration(seconds: 1));
                      }
                      return '';
                    }),
                    builder: (ctx, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return const UnlockScreen();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // LOCALIZATION TEST
      //locale: const Locale('it'),
      supportedLocales: supportedLocales,
    );
  }
}

const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('it'),
  Locale('ru'),
  Locale('zh'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];
