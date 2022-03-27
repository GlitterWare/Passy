import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'entry_event.dart';

class History {
  final Map<DateTime, EntryEvent> passwords;
  final Map<String, EntryEvent> passwordIcons;
  final Map<DateTime, EntryEvent> notes;
  final Map<DateTime, EntryEvent> paymentCards;
  final Map<DateTime, EntryEvent> idCards;
  final Map<DateTime, EntryEvent> identities;

  final File _file;

  Encrypter _encrypter;
  set encrypter(Encrypter encrypter) => _encrypter = encrypter;

  Future<void> save() =>
      _file.writeAsString(encrypt(jsonEncode(this), encrypter: _encrypter));
  void saveSync() =>
      _file.writeAsStringSync(encrypt(jsonEncode(this), encrypter: _encrypter));

  History._(
    this._file, {
    required Encrypter encrypter,
    required this.passwords,
    required this.passwordIcons,
    required this.notes,
    required this.paymentCards,
    required this.idCards,
    required this.identities,
  }) : _encrypter = encrypter;

  factory History(
    File file, {
    required Encrypter encrypter,
  }) {
    if (file.existsSync()) {
      Map<String, dynamic> _json =
          jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter));
      return History._(
        file,
        encrypter: encrypter,
        passwords: (_json['passwords'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        passwordIcons: (_json['passwordIcons'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
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
    History _history = History._(file,
        encrypter: encrypter,
        passwords: {},
        passwordIcons: {},
        notes: {},
        paymentCards: {},
        idCards: {},
        identities: {});
    _history.saveSync();
    return _history;
  }

  Map<String, dynamic> toJson() => {
        'passwords': passwords.map(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'passwordIcons':
            passwordIcons.map((key, value) => MapEntry(key, value.toJson())),
        'notes': notes.map(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'paymentCards': paymentCards.map(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'idCards': idCards.map(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'identities': identities.map(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
      };
}
