import 'dart:async';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/synchronization.dart';
import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'common.dart';
import 'entry_event.dart';
import 'history.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';
import 'screen.dart';

class LoadedAccount {
  final AccountCredentialsFile _credentials;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final PasswordsFile _passwords;
  final Images _passwordIcons;
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
        _passwords = PasswordsFile(
            File(path + Platform.pathSeparator + 'passwords.enc'), encrypter),
        _passwordIcons = Images(
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
    _history.value.passwords[password.creationDate] = EntryEvent(
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
  Uint8List? getPasswordIcon(String name) => _passwordIcons.getEntry(name);

  void setPasswordIcon(String name, Uint8List image) {
    _history.value.passwordIcons[name] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwordIcons.setImage(name, image);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.value.entries;

  Note? getNote(String key) => _notes.value.getEntry(key);

  void setNote(Note note) {
    _history.value.notes[note.creationDate] = EntryEvent(
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
    _history.value.paymentCards[paymentCard.creationDate] = EntryEvent(
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
    _history.value.idCards[idCard.creationDate] = EntryEvent(
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
    _history.value.identities[identity.creationDate] = EntryEvent(
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
