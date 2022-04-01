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
          value: History.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    file.createSync(recursive: true);
    HistoryFile _file = HistoryFile._(file, encrypter, value: History());
    _file.saveSync();
    return _file;
  }
}

class History extends JsonConvertable {
  final Map<DateTime, EntryEvent> passwords;
  final Map<String, EntryEvent> passwordIcons;
  final Map<DateTime, EntryEvent> notes;
  final Map<DateTime, EntryEvent> paymentCards;
  final Map<DateTime, EntryEvent> idCards;
  final Map<DateTime, EntryEvent> identities;

  @override
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

  factory History.fromJson(String json) {
    Map<String, dynamic> _json = jsonDecode(json);
    return History(
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

  factory History.fromFile(File file, Encrypter encrypter) =>
      History.fromJson(decrypt(file.readAsStringSync(), encrypter: encrypter));

  History({
    this.passwords = const {},
    this.passwordIcons = const {},
    this.notes = const {},
    this.paymentCards = const {},
    this.idCards = const {},
    this.identities = const {},
  });
}
