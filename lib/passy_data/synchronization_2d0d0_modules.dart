import 'dart:convert';

import 'package:encrypt/encrypt.dart';

import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'loaded_account.dart';
import 'glare/glare_module.dart';
import 'passy_entry.dart';
import 'synchronization_2d0d0_utils.dart' as util;
import 'common.dart';
import 'favorites.dart';

Map<String, GlareModule> buildSynchronization2d0d0Modules({
  required LoadedAccount account,
  required Encrypter encrypter,
  required History history,
  required Favorites favorites,
  Map<EntryType, List<String>>? sharedEntryKeys,
  void Function()? onSetEntry,
  void Function()? onRemoveEntry,
}) {
  Encrypter usernameEncrypter = getPassyEncrypter(account.username);
  String apiVersion =
      DateTime.now().toUtc().isBefore(synchronization2d0d0DeprecationDate)
          ? '2d0d0'
          : '2d0d1';
  bool useNewAuth = // true
      apiVersion == '2d0d1';
  String generateAuth() {
    return util.generateAuth(
        encrypter: encrypter, usernameEncrypter: usernameEncrypter);
  }

  sharedEntryKeys ??= {};
  Map<String, dynamic> sharedEntries =
      sharedEntryKeys.map((entryType, entryKeys) {
    Map<String, EntryEvent> historyEntries = history.getEvents(entryType);
    PassyEntry? Function(String) getEntry = account.getEntry(entryType);
    return MapEntry(
      entryType.name,
      entryKeys.map<Map<String, dynamic>>((e) {
        return {
          'key': e,
          'historyEntry': historyEntries[e],
          'entry': getEntry(e),
        };
      }).toList(),
    );
  });
  return {
    apiVersion: GlareModule(
      name: 'Passy 2.0.0+ Synchronization Modules',
      target: (args) async {
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
          if (useNewAuth) {
            try {
              util.verifyAuth(decoded['auth'],
                  encrypter: encrypter, usernameEncrypter: usernameEncrypter);
            } catch (e) {
              if (e is Map<String, dynamic>) return e;
              rethrow;
            }
            return decoded;
          }
          dynamic _account = decoded['account'];
          if (_account is! Map<String, dynamic>) {
            throw {
              'error': {
                'type': 'Malformed account',
                'description':
                    'Expected type `Map<String, dynamic>`, received type `${_account.runtimeType.toString()}`',
              },
            };
          }
          dynamic username = _account['username'];
          if (username is! String) {
            throw {
              'error': {
                'type': 'Malformed username',
                'description':
                    'Expected type `String`, received type `${username.runtimeType.toString()}`',
              },
            };
          }
          dynamic passwordHash = _account['passwordHash'];
          if (passwordHash is! String) {
            throw {
              'error': {
                'type': 'Malformed password hash',
                'description':
                    'Expected type `String`, received type `${passwordHash.runtimeType.toString()}`',
              },
            };
          }
          if (username != account.username) {
            return {
              'error': {'type': 'Invalid credentials'},
              'description':
                  'Make sure that both accounts have the same username and password. The only viable synchronization option between different accounts is entry sharing.',
            };
          }
          if (passwordHash != account.passwordHash) {
            return {
              'error': {'type': 'Invalid credentials'},
              'description':
                  'Make sure that both accounts have the same username and password. The only viable synchronization option between different accounts is entry sharing.',
            };
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
            Map<String, dynamic> historyJson = history.toJson();
            Map<String, dynamic> favoritesJson = favorites.toJson();
            String historyHash =
                getPassyHash(jsonEncode(historyJson)).toString();
            String favoritesHash =
                getPassyHash(jsonEncode(favoritesJson)).toString();
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
            };
          case 'getHistoryEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            List<EntryType> entryTypes;
            entryTypes = util.getEntryTypes(check['entryTypes']);
            Map<String, dynamic> result = {};
            for (EntryType type in entryTypes) {
              result[type.name] = history
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
            return {
              'entries': entryKeys.map((entryType, entryKeys) {
                Map<String, EntryEvent> historyEntries =
                    history.getEvents(entryType);
                PassyEntry? Function(String) getEntry =
                    account.getEntry(entryType);
                return MapEntry(
                  entryType.name,
                  entryKeys.map<Map<String, dynamic>>((e) {
                    return {
                      'key': e,
                      'historyEntry': historyEntries[e],
                      'entry': getEntry(e),
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
              account: account,
              history: history,
              onRemoveEntry: onRemoveEntry,
              onSetEntry: onSetEntry,
            );
            return {
              'status': {'type': 'Success'}
            };
          case 'getFavoritesEntries':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            List<EntryType> entryTypes;
            entryTypes = util.getEntryTypes(check['entryTypes']);
            Map<String, dynamic> result = {};
            for (EntryType type in entryTypes) {
              result[type.name] = favorites
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
                  favorites.getEvents(entryType);
              for (EntryEvent entryEvent
                  in favoritesEntriesEntry.value.values) {
                localFavoritesEntries[entryEvent.key] = entryEvent;
              }
            }
            await account.saveFavorites();
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
