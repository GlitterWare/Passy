import 'dart:convert';

import 'package:universal_io/io.dart';

import 'entry_event.dart';

class History {
  final Map<DateTime, EntryEvent> passwords;
  final Map<DateTime, EntryEvent> passwordIcons;
  final Map<DateTime, EntryEvent> notes;
  final Map<DateTime, EntryEvent> paymentCards;
  final Map<DateTime, EntryEvent> idCards;
  final Map<DateTime, EntryEvent> identities;

  final File _file;

  Future<void> save() => _file.writeAsString(jsonEncode(this));
  void saveSync() => _file.writeAsStringSync(jsonEncode(this));

  History._(
    this._file, {
    required this.passwords,
    required this.passwordIcons,
    required this.notes,
    required this.paymentCards,
    required this.idCards,
    required this.identities,
  });

  factory History(File file) {
    if (file.existsSync()) {
      Map<String, dynamic> _json = jsonDecode(file.readAsStringSync());
      return History._(
        file,
        passwords: (_json['passwords'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        passwordIcons: (_json['passwordIcons'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        notes: (_json['notes'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        paymentCards: (_json['paymentCards'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        idCards: (_json['idCards'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        identities: (_json['identities'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
      );
    }
    file.createSync();
    return History._(file,
        passwords: {},
        passwordIcons: {},
        notes: {},
        paymentCards: {},
        idCards: {},
        identities: {});
  }

  Map<String, dynamic> toJson() => {
        'passwords': passwords
            .map((key, value) => MapEntry(key.toIso8601String(), value)),
        'passwordIcons': passwordIcons
            .map((key, value) => MapEntry(key.toIso8601String(), value)),
        'notes':
            notes.map((key, value) => MapEntry(key.toIso8601String(), value)),
        'paymentCards': paymentCards
            .map((key, value) => MapEntry(key.toIso8601String(), value)),
        'idCards':
            idCards.map((key, value) => MapEntry(key.toIso8601String(), value)),
        'identities': identities
            .map((key, value) => MapEntry(key.toIso8601String(), value)),
      };
}
