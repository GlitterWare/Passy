import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy/history.dart';
import 'package:passy/passy/id_cards.dart';
import 'package:passy/passy/identities.dart';
import 'package:passy/passy/images.dart';
import 'package:passy/passy/notes.dart';
import 'package:passy/passy/passwords.dart';
import 'package:passy/passy/payment_cards.dart';
import 'package:universal_io/io.dart';

import 'account_info.dart';

class LoadedAccount {
  final AccountInfo _accountInfo;
  final History _history;
  final Passwords _passwords;
  final Images _passwordIcons;
  final Notes _notes;
  final PaymentCards _paymentCards;
  final IDCards _idCards;
  final Identities _identities;

  ///TODO: account info wrappers

  ///TODO: history wrappers

  ///TODO: passwords wrappers

  ///TODO: password icons wrappers

  ///TODO: notes wrappers

  ///TODO: payment cards wrappers

  ///TODO: id cards wrappers

  ///TODO: identities wrappers

  Future<void> save() async {
    await _accountInfo.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _accountInfo.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  LoadedAccount(this._accountInfo, {required Encrypter encrypter})
      : _history = History(
            File(_accountInfo.path + Platform.pathSeparator + 'history.enc')),
        _passwords = Passwords(
            File(_accountInfo.path + Platform.pathSeparator + 'passwords.enc'),
            encrypter: encrypter),
        _passwordIcons = Images(
            _accountInfo.path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = Notes(
            File(_accountInfo.path + Platform.pathSeparator + 'notes.enc'),
            encrypter: encrypter),
        _paymentCards = PaymentCards(
            File(_accountInfo.path +
                Platform.pathSeparator +
                'payment_cards.enc'),
            encrypter: encrypter),
        _idCards = IDCards(
            File(_accountInfo.path + Platform.pathSeparator + 'id_cards.enc'),
            encrypter: encrypter),
        _identities = Identities(
            File(_accountInfo.path + Platform.pathSeparator + 'identities.enc'),
            encrypter: encrypter);
}
