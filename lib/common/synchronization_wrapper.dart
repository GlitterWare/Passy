import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/sync_details_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:passy/main.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/synchronization.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/synchronization_2d0d0_utils.dart' as util;

class SynchronizationWrapper {
  final LoadedAccount _account = data.loadedAccount!;
  final BuildContext _context;
  late Map<String, PasswordMeta> _passwordsMetadata;
  late Map<String, NoteMeta> _notesMetadata;
  late Map<String, PaymentCardMeta> _paymentCardsMetadata;
  late Map<String, IDCardMeta> _idCardsMetadata;
  late Map<String, IdentityMeta> _identitiesMetadata;
  Synchronization? _sync;

  SynchronizationWrapper({required BuildContext context}) : _context = context {
    _passwordsMetadata = _account.passwordsMetadata;
    _notesMetadata = _account.notesMetadata;
    _paymentCardsMetadata = _account.paymentCardsMetadata;
    _idCardsMetadata = _account.idCardsMetadata;
    _identitiesMetadata = _account.identitiesMetadata;
  }

  void _onConnected() {
    Navigator.pushNamed(_context, SplashScreen.routeName);
  }

  void _onSyncComplete(
    SynchronizationResults results, {
    required LoadedAccount account,
    String popUntilRouteName = MainScreen.routeName,
  }) {
    Navigator.popUntil(_context, (r) => r.settings.name == popUntilRouteName);
    Map<EntryType, List<util.ExchangeEntry>>? sharedEntries =
        results.sharedEntries;
    if (sharedEntries != null) {
      if (sharedEntries.isNotEmpty) {
        EntryType? entryType;
        String? entryKey;
        for (MapEntry<EntryType, List<util.ExchangeEntry>> sharedEntriesEntry
            in sharedEntries.entries) {
          List<util.ExchangeEntry> exchangeEntries = sharedEntriesEntry.value;
          if (exchangeEntries.isEmpty) continue;
          util.ExchangeEntry exchangeEntry = exchangeEntries.first;
          PassyEntry? entry = exchangeEntry.entry;
          if (entry == null) continue;
          entryType = sharedEntriesEntry.key;
          entryKey = entry.key;
        }
        if (entryType != null) {
          if (entryKey != null) {
            Navigator.popUntil(
                _context, (r) => r.settings.name == MainScreen.routeName);
            Navigator.pushNamed(
              _context,
              entryTypeToEntriesRouteName(entryType),
            );
            Navigator.pushNamed(_context, entryTypeToEntryRouteName(entryType),
                arguments: account.getEntry(entryType)(entryKey));
          }
        }
      }
    }
    SynchronizationReport report = _sync!.getReport();
    showDialog(
        context: _context,
        builder: (ctx) => AlertDialog(
              shape: PassyTheme.dialogShape,
              title: Text(localizations.synchronizationComplete),
              content: Text(
                  '${localizations.entriesAdded}: ${report.entriesAdded}\n${localizations.entriesRemoved}: ${report.entriesRemoved}\n${localizations.entriesChanged}: ${report.entriesChanged}'),
              actions: [
                TextButton(
                  child: Text(
                    localizations.details,
                    style: const TextStyle(
                        color: PassyTheme.lightContentSecondaryColor),
                  ),
                  onPressed: () => Navigator.pushNamed(
                      navigatorKey.currentContext!, SyncDetailsScreen.routeName,
                      arguments: SyncDetailsScreenArgs(
                        report: report,
                        passwordsMetadata: {
                          ..._passwordsMetadata,
                          ..._account.passwordsMetadata,
                        }..removeWhere((key, value) =>
                            !report.changedPasswords.keys.contains(key)),
                        notesMetadata: {
                          ..._notesMetadata,
                          ..._account.notesMetadata
                        }..removeWhere((key, value) =>
                            !report.changedNotes.keys.contains(key)),
                        paymentCardsMetadata: {
                          ..._paymentCardsMetadata,
                          ..._account.paymentCardsMetadata
                        }..removeWhere((key, value) =>
                            !report.changedPaymentCards.keys.contains(key)),
                        idCardsMetadata: {
                          ..._idCardsMetadata,
                          ..._account.idCardsMetadata
                        }..removeWhere((key, value) =>
                            !report.changedIDCards.keys.contains(key)),
                        identitiesMetadata: {
                          ..._identitiesMetadata,
                          ..._account.identitiesMetadata,
                        }..removeWhere((key, value) =>
                            !report.changedIdentities.keys.contains(key)),
                      )),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    localizations.close,
                    style: const TextStyle(
                        color: PassyTheme.lightContentSecondaryColor),
                  ),
                ),
              ],
            ));
  }

  void _onSyncError(String log) {
    void _showLog() => navigatorKey.currentState!
        .pushNamed(LogScreen.routeName, arguments: log);
    showSnackBar(
        message: localizations.syncError,
        icon: const Icon(Icons.sync_problem_rounded,
            color: PassyTheme.darkContentColor),
        action:
            SnackBarAction(label: localizations.details, onPressed: _showLog));
  }

  void connect(
    LoadedAccount account, {
    required String address,
    String popUntilRouteName = MainScreen.routeName,
  }) {
    HostAddress _hostAddress;
    try {
      _hostAddress = HostAddress.parse(address);
    } catch (e) {
      showSnackBar(
        message: localizations.invalidAddressFormat,
        icon: const Icon(Icons.sync_problem_rounded,
            color: PassyTheme.darkContentColor),
      );
      return;
    }

    Navigator.pushNamed(_context, SplashScreen.routeName);
    _sync = account.getSynchronization(
      onConnected: () => _onConnected(),
      onComplete: (SynchronizationResults results) => _onSyncComplete(
        results,
        account: account,
        popUntilRouteName: popUntilRouteName,
      ),
      onError: (log) => _onSyncError(log),
    );
    _sync!.connect(_hostAddress).onError((error, stackTrace) {
      showSnackBar(
        message: localizations.connectionFailed,
        icon: const Icon(Icons.sync_problem_rounded,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(_context, LogScreen.routeName,
              arguments: error.toString() + '\n' + stackTrace.toString()),
        ),
      );
    });
  }

  void host(
    LoadedAccount account, {
    Map<EntryType, List<String>>? sharedEntryKeys,
    String popUntilRouteName = MainScreen.routeName,
    Widget? title,
  }) {
    _sync = account.getSynchronization(
      onConnected: _onConnected,
      onComplete: (results) => _onSyncComplete(
        results,
        account: account,
        popUntilRouteName: popUntilRouteName,
      ),
      onError: _onSyncError,
    );
    _sync!
        .host(onConnected: _onConnected, sharedEntryKeys: sharedEntryKeys)
        .then((value) {
      if (value == null) return;
      showDialog(
        context: _context,
        builder: (_) => SimpleDialog(
          title: title,
          shape: PassyTheme.dialogShape,
          children: [
            Center(
              child: SizedBox(
                width: 300,
                height: 350,
                child: Column(
                  children: [
                    QrImageView(
                      data: value.toString(),
                      eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square, color: Colors.blue[50]),
                      dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.blue[50]),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(value.toString()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).whenComplete(() {
        try {
          _sync!.close();
        } catch (e) {
          // Ignore exceptions if synchronization is running
        }
      });
    });
  }
}
