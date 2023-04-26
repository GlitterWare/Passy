import 'dart:convert';

import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/history.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/glare/glare_module.dart';

import 'favorites.dart';
import 'passy_entry.dart';

enum _DataCheck {
  entryType,
  entryKey,
}

Map<String, GlareModule> buildSynchronization2d0d0Modules({
  required LoadedAccount account,
  required History history,
  required Favorites favorites,
  void Function()? onSetEntry,
  void Function()? onRemoveEntry,
}) {
  return {
    '2d0d0': GlareModule(
      name: 'Passy 2.0.0+ Synchronization Modules',
      target: (args) async {
        if (args.length == 3) {
          return {
            'commands': [
              {'name': 'getUsers'},
              {'name': 'getHistoryHash'},
              {'name': 'getEntryKeys'},
              {'name': 'getHistoryEntry'},
              {'name': 'getEntry'},
              {'name': 'setEntry'},
              {'name': 'getFavoritesHash'},
              {'name': 'getFavoritesEntries'},
              {'name': 'setFavoritesEntry'},
              {'name': 'deleteSharedUser'},
              {'name': 'addSharedUser'},
              {'name': 'changeSharedUserPassword'},
            ]
          };
        }
        Map<String, dynamic> checkArgs(List<String> args,
            {List<_DataCheck>? checks}) {
          if (args.length == 4) {
            return {
              'error': {'type': 'Missing arguments'},
            };
          }
          Map<String, dynamic> decoded;
          try {
            decoded = jsonDecode(args[4]);
          } catch (e) {
            return {
              'error': {
                'type': 'Could not decode arguments',
                'exception': e.toString(),
              },
            };
          }
          dynamic _account = decoded['account'];
          if (_account is! Map<String, dynamic>) {
            return {
              'error': {
                'type': 'Malformed account',
                'description':
                    'Expected type `Map<String, dynamic>`, received type `${_account.runtimeType.toString()}`',
              },
            };
          }
          dynamic username = _account['username'];
          if (username is! String) {
            return {
              'error': {
                'type': 'Malformed username',
                'description':
                    'Expected type `String`, received type `${username.runtimeType.toString()}`',
              },
            };
          }
          if (username != account.username) {
            return {
              'error': {
                'type': 'No account available under the specified username'
              },
            };
          }
          dynamic passwordHash = _account['passwordHash'];
          if (passwordHash is! String) {
            return {
              'error': {
                'type': 'Malformed password hash',
                'description':
                    'Expected type `String`, received type `${passwordHash.runtimeType.toString()}`',
              },
            };
          }
          if (passwordHash != account.passwordHash) {
            return {
              'error': {'type': 'Passwords do not match'},
            };
          }
          if (checks == null) return decoded;
          if (checks.isEmpty) return decoded;
          for (_DataCheck check in checks) {
            switch (check) {
              case _DataCheck.entryType:
                dynamic entryTypeName = decoded['entryType'];
                if (entryTypeName is! String) {
                  return {
                    'error': {
                      'type': 'Malformed entry type',
                      'description':
                          'Expected type `String`, received type `${entryTypeName.runtimeType.toString()}`',
                    },
                  };
                }
                EntryType? entryType = entryTypeFromName(entryTypeName);
                if (entryType == null) {
                  return {
                    'error': {
                      'type': 'Unknown entry type',
                      'description': 'Received: `$entryTypeName`',
                    },
                  };
                }
                continue;
              case _DataCheck.entryKey:
                dynamic entryKey = decoded['entryKey'];
                if (entryKey is! String) {
                  return {
                    'error': {
                      'type': 'Malformed entry key',
                      'description':
                          'Expected type `String`, received type `${entryKey.runtimeType.toString()}`',
                    },
                  };
                }
                continue;
            }
          }
          return decoded;
        }

        switch (args[3]) {
          case 'getUsers':
            List<Map<String, dynamic>> users = [
              {
                'username': account.username,
                'type': 'main',
              }
            ];
            return {
              'users': users,
            };
          case 'getHistoryHash':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            return {
              'historyHash': account.historyHash.toString(),
            };
          case 'getEntryKeys':
            Map<String, dynamic> check =
                checkArgs(args, checks: [_DataCheck.entryType]);
            if (check.containsKey('error')) return check;
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            return {'entryKeys': history.getKeys(entryType).toList()};
          case 'getHistoryEntry':
            Map<String, dynamic> check = checkArgs(args,
                checks: [_DataCheck.entryType, _DataCheck.entryKey]);
            if (check.containsKey('error')) return check;
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            String entryKey = check['entryKey'];
            EntryEvent? historyEntry = history.getEvents(entryType)[entryKey];
            return {'historyEntry': historyEntry?.toJson()};
          case 'getEntry':
            Map<String, dynamic> check =
                checkArgs(args, checks: [_DataCheck.entryType]);
            if (check.containsKey('error')) return check;
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            String entryKey = check['entryKey'];
            EntryEvent? historyEntry = history.getEvents(entryType)[entryKey];
            PassyEntry<dynamic>? entry = account.getEntry(entryType)(entryKey);
            return {
              'historyEntry': historyEntry?.toJson(),
              'entry': entry?.toJson(),
            };
          case 'setEntry':
            Map<String, dynamic> check =
                checkArgs(args, checks: [_DataCheck.entryType]);
            if (check.containsKey('error')) return check;
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            dynamic historyEntry = check['historyEntry'];
            if (historyEntry is! Map<String, dynamic>) {
              return {
                'error': {
                  'type': 'Malformed history entry',
                  'description':
                      'Expected type `Map<String, dynamic>`, received type `${historyEntry.runtimeType.toString()}`',
                },
              };
            }
            EntryEvent historyEntryDecoded;
            try {
              historyEntryDecoded = EntryEvent.fromJson(historyEntry);
            } catch (e) {
              return {
                'error': {
                  'type': 'Failed to decode history entry',
                  'exception': e.toString(),
                },
              };
            }
            if (historyEntryDecoded.status == EntryStatus.removed) {
              await account.removeEntry(entryType)(historyEntryDecoded.key);
              onRemoveEntry?.call();
              history.getEvents(entryType)[historyEntryDecoded.key] =
                  historyEntryDecoded;
              await account.saveHistory();
              return {
                'status': {'type': 'Success'}
              };
            }
            dynamic entry = check['entry'];
            if (entry is! Map<String, dynamic>) {
              return {
                'error': {
                  'type': 'Malformed entry',
                  'description':
                      'Expected type `Map<String, dynamic>`, received type `${entry.runtimeType.toString()}`',
                },
              };
            }
            PassyEntry<dynamic> entryDecoded;
            try {
              entryDecoded = PassyEntry.fromJson(entryType)(entry);
            } catch (e) {
              return {
                'error': {
                  'type': 'Failed to decode entry',
                  'exception': e.toString(),
                },
              };
            }
            await account.setEntry(entryType)(entryDecoded);
            onSetEntry?.call();
            history.getEvents(entryType)[historyEntryDecoded.key] =
                historyEntryDecoded;
            await account.saveHistory();
            return {
              'status': {'type': 'Success'}
            };
          case 'getFavoritesHash':
            Map<String, dynamic> check = checkArgs(args);
            if (check.containsKey('error')) return check;
            return {
              'favoritesHash': account.favoritesHash.toString(),
            };
          case 'getFavoritesEntries':
            Map<String, dynamic> check =
                checkArgs(args, checks: [_DataCheck.entryType]);
            if (check.containsKey('error')) return check;
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            Map<String, EntryEvent>? favoriteEntries =
                favorites.getEvents(entryType);
            return {
              'entries': favoriteEntries.map<String, dynamic>(
                (key, value) => MapEntry(key, value.toJson()),
              )
            };
          case 'setFavoritesEntry':
            Map<String, dynamic> check =
                checkArgs(args, checks: [_DataCheck.entryType]);
            EntryType entryType = entryTypeFromName(check['entryType'])!;
            dynamic entry = check['entry'];
            if (entry is! Map<String, dynamic>) {
              return {
                'error': {
                  'type': 'Malformed favorites entry',
                  'description':
                      'Expected type `Map<String, dynamic>`, received type `${entry.runtimeType.toString()}`',
                },
              };
            }
            EntryEvent entryDecoded;
            try {
              entryDecoded = EntryEvent.fromJson(entry);
            } catch (e) {
              return {
                'error': {
                  'type': 'Failed to decode favorite entry',
                  'exception': e.toString(),
                },
              };
            }
            favorites.getEvents(entryType)[entryDecoded.key] = entryDecoded;
            await account.saveFavorites();
            return {
              'status': {'type': 'Success'}
            };
          case 'addSharedUser':
            //Map<String, dynamic> check = checkArgs(args);
            //if (check.containsKey('error')) return check;
            break;
          case 'deleteSharedUser':
            //Map<String, dynamic> check = checkArgs(args);
            //if (check.containsKey('error')) return check;
            break;
          case 'changeSharedUserPassword':
            //Map<String, dynamic> check = checkArgs(args);
            //if (check.containsKey('error')) return check;
            break;
        }
        return {
          'error': {'type': 'No such command'}
        };
      },
    ),
  };
}
