import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/encrypted_json_file.dart';

import 'entry_event.dart';
import 'entry_type.dart';
import 'json_convertable.dart';

typedef HistoryFile = EncryptedJsonFile<History>;

class History with JsonConvertable {
  //int version;
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
    //this.version = 0,
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
      : //version = other.version,
        passwords = Map<String, EntryEvent>.from(other.passwords),
        passwordIcons = Map<String, EntryEvent>.from(other.passwordIcons),
        paymentCards = Map<String, EntryEvent>.from(other.paymentCards),
        notes = Map<String, EntryEvent>.from(other.notes),
        idCards = Map<String, EntryEvent>.from(other.idCards),
        identities = Map<String, EntryEvent>.from(other.identities);

  History.fromJson(Map<String, dynamic> json)
      : //version = int.tryParse(json['version']) ?? 0,
        passwords = (json['passwords'] as Map<String, dynamic>)
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

  @override
  Map<String, dynamic> toJson() => {
        //'version': version.toString(),
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

  Map<String, EntryEvent> getEvents(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords;
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

  Iterable<String> getKeys(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords.keys;
      case EntryType.paymentCard:
        return paymentCards.keys;
      case EntryType.note:
        return notes.keys;
      case EntryType.idCard:
        return idCards.keys;
      case EntryType.identity:
        return identities.keys;
      default:
        return {};
    }
  }

  static HistoryFile fromFile(File file, {required Encrypter encrypter}) =>
      HistoryFile.fromFile(file,
          encrypter: encrypter,
          constructor: () => History(),
          fromJson: History.fromJson);

  void clearRemoved() {
    passwords.removeWhere((key, value) => value.status == EntryStatus.removed);
    passwordIcons
        .removeWhere((key, value) => value.status == EntryStatus.removed);
    paymentCards
        .removeWhere((key, value) => value.status == EntryStatus.removed);
    notes.removeWhere((key, value) => value.status == EntryStatus.removed);
    idCards.removeWhere((key, value) => value.status == EntryStatus.removed);
    identities.removeWhere((key, value) => value.status == EntryStatus.removed);
  }

  void renew() {
    DateTime _time = DateTime.now().toUtc();
    passwords.forEach((key, value) {});
    passwordIcons.forEach((key, value) => value.lastModified = _time);
    paymentCards.forEach((key, value) => value.lastModified = _time);
    notes.forEach((key, value) => value.lastModified = _time);
    idCards.forEach((key, value) => value.lastModified = _time);
    identities.forEach((key, value) => value.lastModified = _time);
  }
}
