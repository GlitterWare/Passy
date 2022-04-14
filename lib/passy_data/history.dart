import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/csv_convertable.dart';
import 'package:universal_io/io.dart';

import 'encrypted_json_file.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'json_convertable.dart';

typedef HistoryFile = EncryptedJsonFile<History>;

class History with JsonConvertable, CSVConvertable {
  final Map<String, EntryEvent> passwords;
  final Map<String, EntryEvent> passwordIcons;
  final Map<String, EntryEvent> paymentCards;
  final Map<String, EntryEvent> notes;
  final Map<String, EntryEvent> idCards;
  final Map<String, EntryEvent> identities;
  int get length =>
      passwords.length +
      passwordIcons.length +
      paymentCards.length +
      notes.length +
      idCards.length +
      identities.length;

  History({
    Map<String, EntryEvent>? passwords,
    Map<String, EntryEvent>? passwordIcons,
    Map<String, EntryEvent>? paymentCards,
    Map<String, EntryEvent>? notes,
    Map<String, EntryEvent>? idCards,
    Map<String, EntryEvent>? identities,
  })  : passwords = passwords ?? {},
        passwordIcons = passwordIcons ?? {},
        notes = notes ?? {},
        paymentCards = paymentCards ?? {},
        idCards = idCards ?? {},
        identities = identities ?? {};

  History.from(History other)
      : passwords = Map<String, EntryEvent>.from(other.passwords),
        passwordIcons = Map<String, EntryEvent>.from(other.passwordIcons),
        paymentCards = Map<String, EntryEvent>.from(other.paymentCards),
        notes = Map<String, EntryEvent>.from(other.notes),
        idCards = Map<String, EntryEvent>.from(other.idCards),
        identities = Map<String, EntryEvent>.from(other.identities);

  History.fromJson(Map<String, dynamic> json)
      : passwords = (json['passwords'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        passwordIcons = (json['passwordIcons'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        paymentCards = (json['paymentCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        notes = (json['notes'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        idCards = (json['idCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        identities = (json['identities'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value)));

  History.fromCSV(List<List> csv)
      : passwords =
            _entriesFromCSV(csv[0].map((e) => e as List<dynamic>).toList()),
        passwordIcons =
            _entriesFromCSV(csv[1].map((e) => e as List<dynamic>).toList()),
        paymentCards =
            _entriesFromCSV(csv[2].map((e) => e as List<dynamic>).toList()),
        notes = _entriesFromCSV(csv[3].map((e) => e as List<dynamic>).toList()),
        idCards =
            _entriesFromCSV(csv[4].map((e) => e as List<dynamic>).toList()),
        identities =
            _entriesFromCSV(csv[5].map((e) => e as List<dynamic>).toList());

  @override
  Map<String, dynamic> toJson() => {
        'passwords': passwords.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'passwordIcons': passwordIcons.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'paymentCards': paymentCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'notes': notes.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'idCards': idCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'identities': identities.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
      };

  @override
  List<List<List>> toCSV() {
    List<List<List>> _csv = [];

    void _addEntries(Iterable<MapEntry<String, EntryEvent>> entries) {
      List<List> _entries = [];
      for (MapEntry<String, EntryEvent> _entry in entries) {
        List _csvEntry = [_entry.key];
        _csvEntry.add(_entry.value.toCSV());
        _entries.add(_csvEntry);
      }
      _csv.add(_entries);
    }

    _addEntries(passwords.entries);
    _addEntries(passwordIcons.entries);
    _addEntries(paymentCards.entries);
    _addEntries(notes.entries);
    _addEntries(idCards.entries);
    _addEntries(identities.entries);

    return _csv;
  }

  Map<String, EntryEvent> getEvents(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords;
      case EntryType.passwordIcon:
        return passwordIcons;
      case EntryType.paymentCard:
        return paymentCards;
      case EntryType.note:
        return notes;
      case EntryType.idCard:
        return idCards;
      case EntryType.identity:
        return identities;
      default:
        return {};
    }
  }

  static Map<String, EntryEvent> _entriesFromCSV(List<List> csv) {
    Map<String, EntryEvent> _entries = {};
    for (List<dynamic> _entry in csv) {
      _entries[_entry[0]] = EntryEvent.fromCSV(_entry[1]);
    }
    return _entries;
  }

  static HistoryFile fromFile(File file, {required Encrypter encrypter}) =>
      HistoryFile.fromFile(file,
          encrypter: encrypter,
          constructor: () => History(),
          fromJson: History.fromJson);
}
