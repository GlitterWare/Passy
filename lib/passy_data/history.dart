import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/json_convertable.dart';

import 'common.dart';
import 'encrypted_json_file.dart';
import 'entry_event.dart';
import 'entry_type.dart';

typedef HistoryFile = EncryptedJsonFile<History>;

class History implements JsonConvertable {
  final Map<String, EntryEvent> passwords;
  final Map<String, EntryEvent> passwordIcons;
  final Map<String, EntryEvent> notes;
  final Map<String, EntryEvent> paymentCards;
  final Map<String, EntryEvent> idCards;
  final Map<String, EntryEvent> identities;
  int get length =>
      passwords.length +
      passwordIcons.length +
      notes.length +
      paymentCards.length +
      idCards.length +
      identities.length;

  History({
    Map<String, EntryEvent>? passwords,
    Map<String, EntryEvent>? passwordIcons,
    Map<String, EntryEvent>? notes,
    Map<String, EntryEvent>? paymentCards,
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
        notes = Map<String, EntryEvent>.from(other.notes),
        paymentCards = Map<String, EntryEvent>.from(other.paymentCards),
        idCards = Map<String, EntryEvent>.from(other.idCards),
        identities = Map<String, EntryEvent>.from(other.identities);

  History.fromJson(Map<String, dynamic> json)
      : passwords = (json['passwords'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        passwordIcons = (json['passwordIcons'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        notes = (json['notes'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        paymentCards = (json['paymentCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        idCards = (json['idCards'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value))),
        identities = (json['identities'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, EntryEvent.fromJson(value)));

  @override
  Map<String, dynamic> toJson() => {
        'passwords': passwords.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'passwordIcons': passwordIcons.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'notes': notes.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'paymentCards': paymentCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'idCards': idCards.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
        'identities': identities.map<String, dynamic>(
            (key, value) => MapEntry(key, value.toJson())),
      };

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

  static HistoryFile fromFile(File file, {required Encrypter encrypter}) =>
      HistoryFile.fromFile(file,
          encrypter: encrypter,
          constructor: () => History(),
          fromJson: History.fromJson);
}
