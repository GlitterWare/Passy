import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/json_convertable.dart';

import 'common.dart';
import 'encrypted_json_file.dart';
import 'entry_event.dart';

class HistoryFile extends EncryptedJsonFile<History> {
  HistoryFile._(File file, Encrypter encrypter, {required History value})
      : super(file, encrypter, value: value);

  factory HistoryFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return HistoryFile._(file, encrypter,
          value: History.fromFile(file, encrypter));
    }
    file.createSync(recursive: true);
    HistoryFile _file = HistoryFile._(file, encrypter, value: History());
    _file.saveSync();
    return _file;
  }
}

class History implements JsonConvertable {
  final Map<DateTime, EntryEvent> passwords;
  final Map<String, EntryEvent> passwordIcons;
  final Map<DateTime, EntryEvent> notes;
  final Map<DateTime, EntryEvent> paymentCards;
  final Map<DateTime, EntryEvent> idCards;
  final Map<DateTime, EntryEvent> identities;

  @override
  Map<String, dynamic> toJson() => {
        'passwords': passwords.map<String, dynamic>(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'passwordIcons': passwordIcons.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'notes': notes.map<String, dynamic>(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'paymentCards': paymentCards.map<String, dynamic>(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'idCards': idCards.map<String, dynamic>(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
        'identities': identities.map<String, dynamic>(
            (key, value) => MapEntry(key.toIso8601String(), value.toJson())),
      };

  factory History.fromJson(Map<String, dynamic> json) => History(
        passwords: (json['passwords'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        passwordIcons: (json['passwordIcons'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        notes: (json['notes'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        paymentCards: (json['paymentCards'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        idCards: (json['idCards'] as Map<String, dynamic>).map((key, value) =>
            MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
        identities: (json['identities'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(DateTime.parse(key), EntryEvent.fromJson(value))),
      );

  factory History.fromFile(File file, Encrypter encrypter) => History.fromJson(
      jsonDecode(decrypt(file.readAsStringSync(), encrypter: encrypter)));

  History({
    Map<DateTime, EntryEvent>? passwords,
    Map<String, EntryEvent>? passwordIcons,
    Map<DateTime, EntryEvent>? notes,
    Map<DateTime, EntryEvent>? paymentCards,
    Map<DateTime, EntryEvent>? idCards,
    Map<DateTime, EntryEvent>? identities,
  })  : passwords = passwords ?? {},
        passwordIcons = passwordIcons ?? {},
        notes = notes ?? {},
        paymentCards = paymentCards ?? {},
        idCards = idCards ?? {},
        identities = identities ?? {};
}
