import 'dart:async';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'note.dart';
import 'password.dart';
import 'passy_bytes.dart';
import 'passy_entry.dart';
import 'payment_card.dart';
import 'screen.dart';
import 'synchronization.dart';

class LoadedAccount {
  final AccountCredentialsFile _credentials;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final PasswordsJsonFile _passwords;
  final PassyImages _passwordIcons;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;
  Encrypter _encrypter;

  LoadedAccount(
    AccountCredentialsFile credentials, {
    required String path,
    required Encrypter encrypter,
  })  : _encrypter = encrypter,
        _credentials = credentials,
        _settings = AccountSettingsFile(
            File(path + Platform.pathSeparator + 'settings.enc'), encrypter),
        _history = HistoryFile(
            File(path + Platform.pathSeparator + 'history.enc'), encrypter),
        _passwords = PasswordsJsonFile(
            File(path + Platform.pathSeparator + 'passwords.enc'), encrypter),
        _passwordIcons = PassyImages(
            path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = NotesFile(
            File(path + Platform.pathSeparator + 'notes.enc'), encrypter),
        _paymentCards = PaymentCardsFile(
            File(path + Platform.pathSeparator + 'payment_cards.enc'),
            encrypter),
        _idCards = IDCardsFile(
            File(path + Platform.pathSeparator + 'id_cards.enc'), encrypter),
        _identities = IdentitiesFile(
            File(path + Platform.pathSeparator + 'identities.enc'), encrypter);

  void _setAccountPassword(String password) {
    _credentials.value.password = password;
    _encrypter = getEncrypter(password);
    _settings.encrypter = _encrypter;
    _history.encrypter = _encrypter;
    _passwords.encrypter = _encrypter;
    _passwordIcons.encrypter = _encrypter;
    _notes.encrypter = _encrypter;
    _paymentCards.encrypter = _encrypter;
    _idCards.encrypter = _encrypter;
    _identities.encrypter = _encrypter;
  }

  Future<void> setAccountPassword(String password) {
    _setAccountPassword(password);
    return save();
  }

  void setAccountPasswordSync(String password) {
    _setAccountPassword(password);
    saveSync();
  }

  Future<void> save() async {
    await _settings.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _settings.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  Future<HostAddress?> host({required BuildContext context}) =>
      Synchronization(this,
              history: _history.value,
              passwords: _passwords.value,
              passwordIcons: _passwordIcons,
              notes: _notes.value,
              paymentCards: _paymentCards.value,
              idCards: _idCards.value,
              identities: _identities.value,
              encrypter: _encrypter,
              context: context)
          .host();

  Future<void> connect(HostAddress address, {required BuildContext context}) =>
      Synchronization(this,
              history: _history.value,
              passwords: _passwords.value,
              passwordIcons: _passwordIcons,
              notes: _notes.value,
              paymentCards: _paymentCards.value,
              idCards: _idCards.value,
              identities: _identities.value,
              encrypter: _encrypter,
              context: context)
          .connect(address);

  void setEntry(EntryType type, PassyEntry value) {
    switch (type) {
      case EntryType.password:
        return setPassword(value as Password);
      case EntryType.passwordIcon:
        return setPasswordIcon(value as PassyBytes);
      case EntryType.paymentCard:
        return setPaymentCard(value as PaymentCard);
      case EntryType.note:
        return setNote(value as Note);
      case EntryType.idCard:
        return setIDCard(value as IDCard);
      case EntryType.identity:
        return setIdentity(value as Identity);
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  PassyEntry? getEntry(EntryType type, String key) {
    switch (type) {
      case EntryType.password:
        return getPassword(key);
      case EntryType.passwordIcon:
        return getPasswordIcon(key);
      case EntryType.paymentCard:
        return getPaymentCard(key);
      case EntryType.note:
        return getNote(key);
      case EntryType.idCard:
        return getIDCard(key);
      case EntryType.identity:
        return getIdentity(key);
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  void removeEntry(EntryType type, String key) {
    switch (type) {
      case EntryType.password:
        return removePassword(key);
      case EntryType.passwordIcon:
        return removePasswordIcon(key);
      case EntryType.paymentCard:
        return removePaymentCard(key);
      case EntryType.note:
        return removeNote(key);
      case EntryType.idCard:
        return removeIDCard(key);
      case EntryType.identity:
        return removeIdentity(key);
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  // Account Credentials wrappers
  String get username => _credentials.value.username;
  set username(String value) => _credentials.value.username = value;
  String get passwordHash => _credentials.value.passwordHash;

  // Account Info wrappers
  String get icon => _settings.value.icon;
  set icon(String value) => _settings.value.icon = value;
  Color get color => _settings.value.color;
  set color(Color value) => _settings.value.color = color;
  Screen get defaultScreen => _settings.value.defaultScreen;
  set defaultScreen(Screen value) => _settings.value.defaultScreen = value;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.value.entries;

  Password? getPassword(String key) => _passwords.value.getEntry(key);

  void setPassword(Password password) {
    _history.value.passwords[password.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.value.setEntry(password);
  }

  void removePassword(String key) {
    _history.value.passwords[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _passwords.value.removeEntry(key);
  }

  // Password Icons wrappers
  PassyBytes? getPasswordIcon(String name) => _passwordIcons.getEntry(name);

  void setPasswordIcon(PassyBytes passwordIcon) {
    _history.value.passwordIcons[passwordIcon.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwordIcons.setEntry(passwordIcon);
  }

  void removePasswordIcon(String key) {
    _history.value.passwordIcons[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _passwordIcons.removeEntry(key);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.value.entries;

  Note? getNote(String key) => _notes.value.getEntry(key);

  void setNote(Note note) {
    _history.value.notes[note.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _notes.value.setEntry(note);
  }

  void removeNote(String key) {
    _history.value.notes[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _notes.value.removeEntry(key);
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.value.entries;

  PaymentCard? getPaymentCard(String key) => _paymentCards.value.getEntry(key);

  void setPaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _paymentCards.value.setEntry(paymentCard);
  }

  void removePaymentCard(String key) {
    _history.value.paymentCards[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _paymentCards.value.removeEntry(key);
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.value.entries;

  IDCard? getIDCard(String key) => _idCards.value.getEntry(key);

  void setIDCard(IDCard idCard) {
    _history.value.idCards[idCard.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _idCards.value.setEntry(idCard);
  }

  void removeIDCard(String key) {
    _history.value.idCards[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _idCards.value.removeEntry(key);
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.value.entries;

  Identity? getIdentity(String key) => _identities.value.getEntry(key);

  void setIdentity(Identity identity) {
    _history.value.identities[identity.key] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _identities.value.setEntry(identity);
  }

  void removeIdentity(String key) {
    _history.value.identities[key]!
      ..status = EntryStatus.deleted
      ..lastModified = DateTime.now().toUtc();
    _identities.value.removeEntry(key);
  }
}