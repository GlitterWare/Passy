import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

class AccountData {
  List<Password> passwords = [];
  List<Note> notes = [];
  List<PaymentCard> paymentCards = [];
  List<IDCard> idCards = [];
  List<Identity> identities = [];

  File _file;
  Encrypter _encrypter;

  String _encrypt(Encrypter encrypter) => encrypter
      .encrypt(
        jsonEncode(this),
        iv: IV.fromLength(16),
      )
      .base64;

  Future<void> save() async => await _file.writeAsString(_encrypt(_encrypter));
  void saveSync() => _file.writeAsStringSync(_encrypt(_encrypter));

  AccountData._(this._file, this._encrypter);

  factory AccountData(File file, Encrypter encrypter) {
    AccountData _data;
    if (!file.existsSync()) {
      file.createSync();
      _data = AccountData._(file, encrypter);
      _data.saveSync();
      return _data;
    }
    Map<String, dynamic> _json = jsonDecode(
        encrypter.decrypt64(file.readAsStringSync(), iv: IV.fromLength(16)));
    _data = AccountData._(file, encrypter)
      ..passwords = (_json['passwords'] as List<dynamic>)
          .map((e) => Password.fromJson(e as Map<String, dynamic>))
          .toList()
      ..notes = (_json['notes'] as List<dynamic>)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList()
      ..paymentCards = (_json['paymentCards'] as List<dynamic>)
          .map((e) => PaymentCard.fromJson(e as Map<String, dynamic>))
          .toList()
      ..idCards = (_json['idCards'] as List<dynamic>)
          .map((e) => IDCard.fromJson(e as Map<String, dynamic>))
          .toList()
      ..identities = (_json['identities'] as List<dynamic>)
          .map((e) => Identity.fromJson(e as Map<String, dynamic>))
          .toList();
    _data._file = file;
    _data._encrypter = encrypter;
    return _data;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'passwords': passwords,
        'notes': notes,
        'paymentCards': paymentCards,
        'idCards': idCards,
        'identities': identities,
      };

  Map<String, dynamic> toJson() => toMap();
}
