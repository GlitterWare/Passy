import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/account_credentials.dart';
import 'package:passy/passy_data/account_settings.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';

import 'file_sync_history.dart';
import 'passy_entries_file_collection.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'glare/glare_module.dart';
import 'passy_entry.dart';
import 'sync_entry_state.dart';
import 'synchronization_2d0d0_utils.dart' as util;
import 'common.dart';
import 'favorites.dart';

Map<String, GlareModule> buildSynchronization2d0d0Modules({
  required String username,
  required FullPassyEntriesFileCollection passyEntries,
  required Encrypter encrypter,
  required HistoryFile history,
  required FileSyncHistoryFile fileSyncHistory,
  required FavoritesFile favorites,
  required AccountSettingsFile settings,
  required AccountCredentialsFile credentials,
  required authWithIV,
  Map<EntryType, List<String>>? sharedEntryKeys,
  void Function(EntryType type, String key, SyncEntryState state)?
      onEntryChanged,
}) {
  history.reloadSync();
  Encrypter usernameEncrypter = getPassyEncrypter(username);
  String apiVersion = '2d0d1';
  String generateAuth() {
    return util.generateAuth(
        encrypter: encrypter,
        usernameEncrypter: usernameEncrypter,
        withIV: authWithIV);
  }

  sharedEntryKeys ??= {};
  Map<String, dynamic> sharedEntries =
      sharedEntryKeys.map((entryType, entryKeys) {
    Map<String, EntryEvent> historyEntries = history.value.getEvents(entryType);
    Map<String, PassyEntry> entries =
        passyEntries.getEntries(entryType).getEntries(entryKeys);
    return MapEntry(
      entryType.name,
      entryKeys.map<Map<String, dynamic>>((e) {
        return {
          'key': e,
          'historyEntry': historyEntries[e],
          'entry': entries[e],
        };
      }).toList(),
    );
  });
  return {
    apiVersion: GlareModule(
      name: 'Passy 2.0.0+ Synchronization Modules',
      target: (
        args, {
        required addModule,
        Map<String, List<int>>? binaryObjects,
      }) async {
        String lastAuth = '';
        DateTime lastDate =
            DateTime.now().toUtc().subtract(const Duration(hours: 12));
        if (args.length == 3) {
          return {
            'commands': [
              {'name': 'checkAccount'},
              {'name': 'authenticate'},
              {'name': 'getHashes'},
              {'name': 'getHistoryEntries'},
              {'name': 'getEntries'},
              {'name': 'getSharedEntries'},
              {'name': 'setEntries'},
              {'name': 'getFavoritesEntries'},
              {'name': 'setFavoritesEntries'},
              {'name': 'getFileSyncHistoryEntries'},
              {'name': 'getFile'},
              {'name': 'setFile'},
            ]
          };
        }

        Map<String, dynamic> checkArgs(List<String> args) {
          if (args.length == 4) {
            throw {
              'error': {'type': 'Missing arguments'},
            };
          }
          Map<String, dynamic> decoded;
          try {
            decoded = jsonDecode(args[4]);
          } catch (e) {
            throw {
              'error': {
                'type': 'Could not decode arguments',
                'exception': e.toString(),
              },
            };
          }
          try {
            lastDate = util.verifyAuth(decoded['auth'],
                lastAuth: lastAuth,
                lastDate: lastDate,
                encrypter: encrypter,
                usernameEncrypter: usernameEncrypter,
                withIV: authWithIV);
            lastAuth = decoded['auth'];
          } catch (e) {
            if (e is Map<String, dynamic>) return e;
            rethrow;
          }
          return decoded;
        }

        switch (args[3]) {
          case 'checkAccount':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            return {
              'status': {'type': 'Success'}
            };
          case 'getAccountCredentials':
            await credentials.reload();
            Map<String, dynamic> credsJson = credentials.value.toJson();
            credsJson.remove('passwordHash');
            credsJson.remove('bioAuthEnabled');
            return {
              'credentials': credsJson,
            };
          case 'authenticate':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            return {
              'status': {'type': 'Success'},
              'auth': generateAuth(),
            };
          case 'getHashes':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            await Future.wait([
              history.reload(),
              favorites.reload(),
            ]);
            Map<String, dynamic> historyJson = history.value.toJson();
            Map<String, dynamic> favoritesJson = favorites.value.toJson();
            Map<String, dynamic> fileSyncHistoryJson =
                fileSyncHistory.value.toJson();
            String historyHash =
                getPassyHash(jsonEncode(historyJson)).toString();
            String favoritesHash =
                getPassyHash(jsonEncode(favoritesJson)).toString();
            String fileSyncHistoryHash =
                getPassyHash(jsonEncode(fileSyncHistoryJson)).toString();
            //String filesHash =
            //    getPassyHash(jsonEncode(fileSyncHistoryJson['files']))
            //        .toString();
            Map<String, dynamic> historyHashes = {};
            Map<String, dynamic> favoritesHashes = {};
            for (EntryType entryType in [
              EntryType.password,
              EntryType.paymentCard,
              EntryType.note,
              EntryType.idCard,
              EntryType.identity
            ]) {
              String entryTypeName = entryType.name;
              String entryTypeNamePlural = entryTypeToNamePlural(entryType);
              historyHashes[entryTypeName] =
                  getPassyHash(jsonEncode(historyJson[entryTypeNamePlural]))
                      .toString();
              favoritesHashes[entryTypeName] =
                  getPassyHash(jsonEncode(favoritesJson[entryTypeNamePlural]))
                      .toString();
            }
            return {
              'historyHash': historyHash,
              'historyHashes': historyHashes,
              'favoritesHash': favoritesHash,
              'favoritesHashes': favoritesHashes,
              'fileSyncHistoryHash': fileSyncHistoryHash,
              //'fileSyncHistoryHashes': {
              //  'files': filesHash,
              //},
            };
          case 'getHistoryEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            List<EntryType> entryTypes;
            entryTypes = util.getEntryTypes(check['entryTypes']);
            Map<String, dynamic> result = {};
            await history.reload();
            for (EntryType type in entryTypes) {
              result[type.name] = history.value
                  .getEvents(type)
                  .values
                  .map<Map<String, dynamic>>((value) => value.toJson())
                  .toList();
            }
            return {
              'historyEntries': result,
            };
          case 'getEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            Map<EntryType, List<String>> entryKeys;
            entryKeys = util.getEntryKeys(check['entryKeys']);
            await history.reload();
            return {
              'entries': entryKeys.map((entryType, entryKeys) {
                Map<String, EntryEvent> historyEntries =
                    history.value.getEvents(entryType);
                Map<String, PassyEntry> entries =
                    passyEntries.getEntries(entryType).getEntries(entryKeys);
                return MapEntry(
                  entryType.name,
                  entryKeys.map<Map<String, dynamic>>((e) {
                    return {
                      'key': e,
                      'historyEntry': historyEntries[e],
                      'entry': entries[e],
                    };
                  }).toList(),
                );
              }),
            };
          case 'getSharedEntries':
            return {
              'entries': sharedEntries,
            };
          case 'setEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            Map<EntryType, List<util.ExchangeEntry>> exchangeEntries;
            exchangeEntries = util.getEntries(check['entries']);
            await util.processTypedExchangeEntries(
              entries: exchangeEntries,
              passyEntries: passyEntries,
              history: history,
              onEntryChanged: onEntryChanged,
            );
            await settings.reload();
            settings.value.lastSyncDate = DateTime.now().toUtc();
            await settings.save();
            return {
              'status': {'type': 'Success'}
            };
          case 'getFavoritesEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            await favorites.reload();
            List<EntryType> entryTypes;
            entryTypes = util.getEntryTypes(check['entryTypes']);
            Map<String, dynamic> result = {};
            for (EntryType type in entryTypes) {
              result[type.name] = favorites.value
                  .getEvents(type)
                  .values
                  .map<Map<String, dynamic>>((value) => value.toJson())
                  .toList();
            }
            return {
              'favoritesEntries': result,
            };
          case 'setFavoritesEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            await favorites.reload();
            Map<EntryType, Map<String, EntryEvent>> favoritesEntries =
                util.getTypedEntryEvents(check['favoritesEntries']);
            for (MapEntry<EntryType,
                    Map<String, EntryEvent>> favoritesEntriesEntry
                in favoritesEntries.entries) {
              EntryType entryType = favoritesEntriesEntry.key;
              Map<String, EntryEvent>? typeFavoritesEntries =
                  favoritesEntries[entryType];
              if (typeFavoritesEntries == null) continue;
              Map<String, EntryEvent> localFavoritesEntries =
                  favorites.value.getEvents(entryType);
              for (EntryEvent entryEvent
                  in favoritesEntriesEntry.value.values) {
                localFavoritesEntries[entryEvent.key] = entryEvent;
              }
            }
            await favorites.save();
            return {
              'status': {'type': 'Success'}
            };
          case 'getFileSyncHistoryEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            Map<String, dynamic> result = {};
            await fileSyncHistory.reload();
            result['files'] = fileSyncHistory.value.files.values
                .map<Map<String, dynamic>>((value) => value.toJson())
                .toList();
            return {
              'historyEntries': result,
            };
          case 'getFile':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            String entryKey = check['entryKey'];
            await fileSyncHistory.reload();
            EntryEvent? historyEntry = fileSyncHistory.value.files[entryKey];
            PassyFsMeta? fsMeta =
                (await passyEntries.fileIndex!.getEntry(entryKey));
            Map<String, dynamic> result = {
              'entryKey': entryKey,
              'fsMeta': fsMeta?.toJson(),
              'historyEntry': historyEntry,
            };
            if (fsMeta != null) {
              result['binaryObjects'] = {
                'file': (await passyEntries.fileIndex!.readAsBytes(entryKey))
                    .toList(),
              };
            }
            return result;
          case 'setFile':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            String key = check['entryKey'];
            FileMeta? remoteFsMeta;
            Map<String, dynamic>? remoteFsMetaJson = check['fsMeta'];
            if (remoteFsMetaJson != null) {
              try {
                dynamic fsType = remoteFsMetaJson['fsType'];
                if (fsType != 'f') {
                  throw Exception(
                      'Unsupported Passy filesystem type: `$fsType`.');
                }
                remoteFsMeta = FileMeta.fromJson(remoteFsMetaJson);
              } catch (e, s) {
                throw ('Failed to decode Passy filesystem metadata:\n$e\n$s`.');
              }
            }
            EntryEvent remoteHistoryEntry;
            try {
              remoteHistoryEntry = EntryEvent.fromJson(check['historyEntry']);
            } catch (e, s) {
              throw 'Failed to decode history entry:\n$e\n$s`.';
            }
            passyEntries.fileIndex!.removeFile(key);
            if (binaryObjects != null && remoteFsMeta != null) {
              if (binaryObjects.isNotEmpty) {
                // Save file
                passyEntries.fileIndex!.addBytes(
                    Uint8List.fromList(binaryObjects.values.first),
                    meta: remoteFsMeta);
              }
            }
            await fileSyncHistory.reload();
            fileSyncHistory.value.files[key] = remoteHistoryEntry;
            await fileSyncHistory.save();
            return {
              'status': {'type': 'Success'}
            };
        }
        throw {
          'error': {'type': 'No such command'}
        };
      },
    ),
  };
}
