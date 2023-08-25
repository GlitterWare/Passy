import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_entries_encrypted_csv_file.dart';
import 'package:passy/passy_data/passy_entries_file_collection.dart';
import 'package:passy/passy_data/payment_card.dart';

import 'history.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'passy_entry.dart';

class EntriesToSynchronize {
  Map<EntryType, List<String>> entriesToSend;
  Map<EntryType, List<String>> entriesToRetrieve;

  EntriesToSynchronize({
    required this.entriesToSend,
    required this.entriesToRetrieve,
  });
}

class ExchangeEntry {
  String key;
  EntryEvent? historyEntry;
  PassyEntry? entry;

  ExchangeEntry({
    required this.key,
    required this.historyEntry,
    required this.entry,
  });
}

EntryType getEntryType(dynamic entryTypeName) {
  if (entryTypeName is! String) {
    throw {
      'error': {
        'type': 'Malformed entry type',
        'description':
            'Expected type `String`, received type `${entryTypeName.runtimeType.toString()}`',
      },
    };
  }
  EntryType? entryType = entryTypeFromName(entryTypeName);
  if (entryType == null) {
    throw {
      'error': {
        'type': 'Unknown entry type',
        'description': 'Received: `$entryTypeName`',
      },
    };
  }
  return entryType;
}

List<EntryType> getEntryTypes(dynamic entryTypes) {
  if (entryTypes is! List<dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entry types',
        'description':
            'Expected type `List<dynamic>`, received type `${entryTypes.runtimeType.toString()}`',
      },
    };
  }
  List<EntryType> entryTypesDecoded = [];
  for (dynamic entryTypeName in entryTypes) {
    if (entryTypeName is! String) {
      throw {
        'error': {
          'type': 'Malformed entry type',
          'description':
              'Expected type `String`, received type `${entryTypeName.runtimeType.toString()}`',
        },
      };
    }
    EntryType? entryType = entryTypeFromName(entryTypeName);
    if (entryType == null) {
      throw {
        'error': {
          'type': 'Unknown entry type',
          'description': 'Received: `$entryTypeName`',
        },
      };
    }
    entryTypesDecoded.add(entryType);
  }
  return entryTypesDecoded;
}

Map<EntryType, List<String>> getEntryKeys(dynamic entryKeys) {
  if (entryKeys is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entry keys',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${entryKeys.runtimeType.toString()}`',
      },
    };
  }
  Map<EntryType, List<String>> result = {};
  for (MapEntry<String, dynamic> entryKeysEntry in entryKeys.entries) {
    String entryTypeName = entryKeysEntry.key;
    EntryType entryType = getEntryType(entryTypeName);
    dynamic entryKeys = entryKeysEntry.value;
    if (entryKeys is! List<dynamic>) {
      throw {
        'error': {
          'type': 'Malformed entry keys of type $entryTypeName',
          'description':
              'Expected type `List<dynamic>`, received type `${entryKeys.runtimeType.toString()}`',
        },
      };
    }
    List<String> entryKeysDecoded = [];
    result[entryType] = entryKeysDecoded;
    for (dynamic entryKey in entryKeys) {
      if (entryKey is! String) {
        throw {
          'error': {
            'type': 'Malformed entry key of type $entryTypeName',
            'description':
                'Expected type `String`, received type `${entryKeys.runtimeType.toString()}`',
          },
        };
      }
      entryKeysDecoded.add(entryKey);
    }
  }
  return result;
}

String getEntryKey(dynamic entryKey) {
  if (entryKey is! String) {
    throw {
      'error': {
        'type': 'Malformed entry key',
        'description':
            'Expected type `String`, received type `${entryKey.runtimeType.toString()}`',
      },
    };
  }
  return entryKey;
}

PassyEntry getPassyEntry({
  required EntryType entryType,
  required dynamic entry,
}) {
  if (entry is! Map<String, dynamic>) {
    throw {
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
    throw {
      'error': {
        'type': 'Failed to decode entry',
        'exception': e.toString(),
      },
    };
  }
  return entryDecoded;
}

EntryEvent getEntryEvent(dynamic entryEvent) {
  if (entryEvent is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entry event',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${entryEvent.runtimeType.toString()}`',
      },
    };
  }
  EntryEvent entryEventDecoded;
  try {
    entryEventDecoded = EntryEvent.fromJson(entryEvent);
  } catch (e) {
    throw {
      'error': {
        'type': 'Failed to decode history entry',
        'exception': e.toString(),
      },
    };
  }
  return entryEventDecoded;
}

ExchangeEntry getEntry({
  required EntryType entryType,
  required dynamic entry,
}) {
  if (entry is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entry of type $entryType',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${entry.runtimeType.toString()}`',
      },
    };
  }
  dynamic key = entry['key'];
  if (key is! String) {
    throw {
      'error': {
        'type': 'Malformed entry key',
        'description':
            'Expected type `String`, received type `${key.runtimeType.toString()}`',
      },
    };
  }
  EntryEvent? historyEntryDecoded;
  dynamic historyEntry = entry['historyEntry'];
  if (historyEntry != null) {
    historyEntryDecoded = getEntryEvent(historyEntry);
  }
  PassyEntry? entryDecoded;
  dynamic entryEncoded = entry['entry'];
  if (entryEncoded != null) {
    entryDecoded = getPassyEntry(entryType: entryType, entry: entryEncoded);
  }
  return ExchangeEntry(
      key: key, historyEntry: historyEntryDecoded, entry: entryDecoded);
}

Map<EntryType, List<ExchangeEntry>> getEntries(dynamic entries) {
  if (entries is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entries',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${entries.runtimeType.toString()}`',
      },
    };
  }
  Map<EntryType, List<ExchangeEntry>> result = {};
  for (MapEntry<String, dynamic> entriesEntry in entries.entries) {
    String entryTypeName = entriesEntry.key;
    EntryType entryType = getEntryType(entryTypeName);
    dynamic entries = entriesEntry.value;
    if (entries is! List<dynamic>) {
      throw {
        'error': {
          'type': 'Malformed entries of type $entryTypeName',
          'description':
              'Expected type `List<dynamic>`, received type `${entries.runtimeType.toString()}`',
        },
      };
    }
    List<ExchangeEntry> entriesDecoded = [];
    result[entryType] = entriesDecoded;
    for (dynamic entry in entries) {
      ExchangeEntry entryDecoded = getEntry(entryType: entryType, entry: entry);
      entriesDecoded.add(entryDecoded);
    }
  }
  return result;
}

Map<EntryType, String> findEntriesHashes({required Map<String, dynamic> json}) {
  Map<EntryType, String> result = {};
  for (EntryType entryType in [
    EntryType.password,
    EntryType.paymentCard,
    EntryType.note,
    EntryType.idCard,
    EntryType.identity
  ]) {
    String entryTypeNamePlural = entryTypeToNamePlural(entryType);
    result[entryType] =
        getPassyHash(jsonEncode(json[entryTypeNamePlural])).toString();
  }
  return result;
}

Map<EntryType, String> getEntriesHashes(dynamic hashes) {
  if (hashes is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed hashes',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${hashes.runtimeType.toString()}`',
      },
    };
  }
  Map<EntryType, String> hashesDecoded = {};
  for (MapEntry<String, dynamic> hashEntry in hashes.entries) {
    EntryType entryType = getEntryType(hashEntry.key);
    dynamic hash = hashEntry.value;
    if (hash is! String) {
      throw {
        'error': {
          'type': 'Malformed hash',
          'description':
              'Expected type `String`, received type `${hash.runtimeType.toString()}`',
        },
      };
    }
    hashesDecoded[entryType] = hash;
  }
  return hashesDecoded;
}

List<EntryType> findEntryTypesToSynchronize({
  required Map<EntryType, String> localHashes,
  required Map<EntryType, String> remoteHashes,
}) {
  List<EntryType> entryTypes = [];
  for (MapEntry<EntryType, String> remoteHashEntry in remoteHashes.entries) {
    EntryType entryType = remoteHashEntry.key;
    String? localHash = localHashes[entryType];
    if (localHash == null) continue;
    if (localHash == remoteHashEntry.value) continue;
    entryTypes.add(entryType);
  }
  return entryTypes;
}

Map<String, EntryEvent> getEntryEvents(dynamic entryEvents) {
  if (entryEvents is! List<dynamic>) {
    throw {
      'error': {
        'type': 'Malformed entry events',
        'description':
            'Expected type `List<dynamic>`, received type `${entryEvents.runtimeType.toString()}`',
      },
    };
  }
  Map<String, EntryEvent> result = {};
  for (dynamic entryEvent in entryEvents) {
    EntryEvent entryEventDecoded = getEntryEvent(entryEvent);
    result[entryEventDecoded.key] = entryEventDecoded;
  }
  return result;
}

Map<EntryType, Map<String, EntryEvent>> getTypedEntryEvents(
    dynamic typedEntryEvents) {
  if (typedEntryEvents is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed typed entry events',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${typedEntryEvents.runtimeType.toString()}`',
      },
    };
  }
  Map<EntryType, Map<String, EntryEvent>> result = {};
  for (MapEntry<String, dynamic> typedEntryEventsEntry
      in typedEntryEvents.entries) {
    EntryType entryType = getEntryType(typedEntryEventsEntry.key);
    Map<String, EntryEvent> entryEvents =
        getEntryEvents(typedEntryEventsEntry.value);
    result[entryType] = entryEvents;
  }
  return result;
}

EntriesToSynchronize findEntriesToSynchronize({
  required Map<EntryType, Map<String, EntryEvent>> localEntries,
  required Map<EntryType, Map<String, EntryEvent>> remoteEntries,
}) {
  Map<EntryType, List<String>> entriesToSend = {};
  Map<EntryType, List<String>> entriesToRetrieve = {};
  for (MapEntry<EntryType, Map<String, EntryEvent>> localEntriesEntry
      in localEntries.entries) {
    EntryType entryType = localEntriesEntry.key;
    List<String> entriesToSendList = [];
    Map<String, EntryEvent>? remoteEntryEvents = remoteEntries[entryType];
    if (remoteEntryEvents == null) continue;
    Map<String, EntryEvent> localEntryEvents = localEntriesEntry.value;
    Iterable<String> localEntryKeys = localEntryEvents.keys;
    Iterable<String> remoteEntryKeys = remoteEntryEvents.keys;
    for (String key in localEntryKeys) {
      if (remoteEntryKeys.contains(key)) continue;
      entriesToSendList.add(key);
    }
    if (entriesToSendList.isNotEmpty) {
      entriesToSend[entryType] = entriesToSendList;
    }
  }
  for (MapEntry<EntryType, Map<String, EntryEvent>> remoteEntriesEntry
      in remoteEntries.entries) {
    EntryType entryType = remoteEntriesEntry.key;
    List<String>? entriesToSendList = entriesToSend[entryType];
    entriesToSendList ??= [];
    List<String> entriesToRetrieveList = [];
    Map<String, EntryEvent>? localEntryEvents = localEntries[entryType];
    if (localEntryEvents == null) continue;
    Map<String, EntryEvent> remoteEntryEvents = remoteEntriesEntry.value;
    for (MapEntry<String, EntryEvent> remoteEntryEventsEntry
        in remoteEntryEvents.entries) {
      String key = remoteEntryEventsEntry.key;
      EntryEvent? localEntryEvent = localEntryEvents[key];
      if (localEntryEvent == null) {
        entriesToRetrieveList.add(key);
        continue;
      }
      EntryEvent remoteEntryEvent = remoteEntryEventsEntry.value;
      if (localEntryEvent.lastModified
          .isAtSameMomentAs(remoteEntryEvent.lastModified)) {
        continue;
      }
      if (localEntryEvent.lastModified
          .isBefore(remoteEntryEvent.lastModified)) {
        entriesToRetrieveList.add(key);
        continue;
      }
      entriesToSendList.add(key);
    }
    if (entriesToRetrieveList.isNotEmpty) {
      entriesToRetrieve[entryType] = entriesToRetrieveList;
    }
    if (entriesToSendList.isNotEmpty) {
      entriesToSend[entryType] = entriesToSendList;
    }
  }
  return EntriesToSynchronize(
    entriesToSend: entriesToSend,
    entriesToRetrieve: entriesToRetrieve,
  );
}

Future<PassyEntry?> processExchangeEntry({
  required EntryType entryType,
  required ExchangeEntry entry,
  required HistoryFile history,
  void Function()? onRemoveEntry,
  void Function()? onSetEntry,
}) async {
  EntryEvent? historyEntry = entry.historyEntry;
  if (historyEntry == null) {
    throw {'error': 'History entry not provided'};
  }
  if (historyEntry.status == EntryStatus.removed) {
    onRemoveEntry?.call();
    history.value.getEvents(entryType)[historyEntry.key] = historyEntry;
    return null;
  }
  PassyEntry? passyEntry = entry.entry;
  if (passyEntry == null) {
    throw {'error': 'Passy entry not provided'};
  }
  history.value.getEvents(entryType)[historyEntry.key] = historyEntry;
  onSetEntry?.call();
  return passyEntry;
}

Future<void> processExchangeEntries({
  required EntryType entryType,
  required List<ExchangeEntry> entries,
  required PassyEntriesEncryptedCSVFile entriesFile,
  required HistoryFile history,
  void Function()? onRemoveEntry,
  void Function()? onSetEntry,
}) async {
  Map<String, PassyEntry?> passyEntries = {};
  for (ExchangeEntry entry in entries) {
    PassyEntry? passyEntry = await processExchangeEntry(
      entryType: entryType,
      entry: entry,
      history: history,
      onRemoveEntry: onRemoveEntry,
      onSetEntry: onSetEntry,
    );
    passyEntries[entry.key] = passyEntry;
  }
  switch (entryType) {
    case EntryType.password:
      await entriesFile.setEntries(passyEntries.map<String, Password?>(
          (key, value) => MapEntry(key, value as Password?)));
      break;
    case EntryType.paymentCard:
      await entriesFile.setEntries(passyEntries.map<String, PaymentCard?>(
          (key, value) => MapEntry(key, value as PaymentCard?)));
      break;
    case EntryType.note:
      await entriesFile.setEntries(passyEntries
          .map<String, Note?>((key, value) => MapEntry(key, value as Note?)));
      break;
    case EntryType.idCard:
      await entriesFile.setEntries(passyEntries.map<String, IDCard?>(
          (key, value) => MapEntry(key, value as IDCard?)));
      break;
    case EntryType.identity:
      await entriesFile.setEntries(passyEntries.map<String, Identity?>(
          (key, value) => MapEntry(key, value as Identity?)));
      break;
  }
}

Future<void> processTypedExchangeEntries({
  required Map<EntryType, List<ExchangeEntry>> entries,
  required FullPassyEntriesFileCollection passyEntries,
  required HistoryFile history,
  void Function()? onRemoveEntry,
  void Function()? onSetEntry,
}) async {
  await history.reload();
  try {
    for (MapEntry<EntryType, List<ExchangeEntry>> exchangeEntriesEntry
        in entries.entries) {
      EntryType entryType = exchangeEntriesEntry.key;
      List<ExchangeEntry> exchangeEntries = exchangeEntriesEntry.value;
      await processExchangeEntries(
        entryType: entryType,
        entries: exchangeEntries,
        entriesFile: passyEntries.getEntries(entryType),
        history: history,
        onRemoveEntry: onRemoveEntry,
        onSetEntry: onSetEntry,
      );
    }
    await history.save();
  } catch (e) {
    await history.reload();
    rethrow;
  }
}

String generateAuth(
    {required Encrypter encrypter, required Encrypter usernameEncrypter}) {
  return encrypt(
      encrypt(jsonEncode({'date': DateTime.now().toUtc().toIso8601String()}),
          encrypter: usernameEncrypter),
      encrypter: encrypter);
}

void verifyAuth(dynamic auth,
    {required Encrypter encrypter, required Encrypter usernameEncrypter}) {
  if (auth is! String) {
    throw {
      'error': {
        'type': 'Malformed auth',
        'description':
            'Expected type `String`, received type `${auth.runtimeType.toString()}`',
      },
    };
  }
  try {
    auth = decrypt(decrypt(auth, encrypter: encrypter),
        encrypter: usernameEncrypter);
  } catch (e) {
    throw {
      'error': {
        'type': 'Could not decrypt auth',
        'description':
            'Make sure that both accounts have the same username and password. The only viable synchronization option between different accounts is entry sharing.'
      },
    };
  }
  try {
    auth = jsonDecode(auth);
  } catch (e) {
    throw {
      'error': {
        'type': 'Could not decode auth',
        'exception': e.toString(),
      },
    };
  }
  if (auth is! Map<String, dynamic>) {
    throw {
      'error': {
        'type': 'Malformed auth',
        'description':
            'Expected type `Map<String, dynamic>`, received type `${auth.runtimeType.toString()}`',
      },
    };
  }
  dynamic date = auth['date'];
  if (date is! String) {
    throw {
      'error': {
        'type': 'Malformed date',
        'description':
            'Expected type `String`, received type `${date.runtimeType.toString()}`',
      },
    };
  }
  DateTime? dateDecoded = DateTime.tryParse(date);
  if (dateDecoded == null) {
    throw {
      'error': {
        'type': 'Could not decode date',
        'description': 'Received $date',
      },
    };
  }
  if (DateTime.now()
      .toUtc()
      .subtract(const Duration(seconds: 5))
      .isAfter(dateDecoded)) {
    throw {
      'error': {
        'type': 'Stale auth',
        'date': date,
        'description':
            'Packet took too long to reach its destination, please check your network conditions',
      },
    };
  }
}
