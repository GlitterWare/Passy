import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

class AccountData {
  List<Password> passwords;
  Map<String, Uint8List> passwordIcons;
  List<Note> notes;
  List<PaymentCard> paymentCards;
  List<IDCard> idCards;
  List<Identity> identities;

  File _file;
  Encrypter _encrypter;

  String _encrypt(Encrypter encrypter) => encrypter
      .encrypt(
        jsonEncode(this),
        iv: IV.fromLength(16),
      )
      .base64;

  Future<void> save() async {
    sort();
    await _file.writeAsString(_encrypt(_encrypter));
  }

  void saveSync() {
    sort();
    _file.writeAsStringSync(_encrypt(_encrypter));
  }

  AccountData._(
    this._file,
    this._encrypter, {
    required this.passwords,
    required this.passwordIcons,
    required this.notes,
    required this.paymentCards,
    required this.idCards,
    required this.identities,
  });

  factory AccountData(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      Map<String, dynamic> _json = jsonDecode(
          encrypter.decrypt64(file.readAsStringSync(), iv: IV.fromLength(16)));
      return AccountData._(
        file,
        encrypter,
        passwords: (_json['passwords'] as List<dynamic>)
            .map((e) => Password.fromJson(e as Map<String, dynamic>))
            .toList(),
        passwordIcons: (_json['passwordIcons'] as Map<String, dynamic>)
            .map((k, v) => MapEntry<String, Uint8List>(
                k,
                Uint8List.fromList(utf8.encode(encrypter.decrypt64(
                  File(v as String).readAsStringSync(),
                  iv: IV.fromLength(16),
                ))))),
        notes: (_json['notes'] as List<dynamic>)
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentCards: (_json['paymentCards'] as List<dynamic>)
            .map((e) => PaymentCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        idCards: (_json['idCards'] as List<dynamic>)
            .map((e) => IDCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        identities: (_json['identities'] as List<dynamic>)
            .map((e) => Identity.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    file.createSync();
    AccountData _data = AccountData._(
      file,
      encrypter,
      passwords: [],
      passwordIcons: {},
      notes: [],
      paymentCards: [],
      idCards: [],
      identities: [],
    );
    _data.saveSync();
    return _data;
  }

  void sort() => passwords.sort((a, b) => a.nickname.compareTo(b.nickname));

  Map<String, dynamic> toJson() => <String, dynamic>{
        'passwords': passwords,
        'passwordIcons': passwordIcons.map((k, v) => MapEntry<String, dynamic>(
            k,
            _encrypter
                .encryptBytes(
                  v,
                  iv: IV.fromLength(16),
                )
                .base64)),
        'notes': notes,
        'paymentCards': paymentCards,
        'idCards': idCards,
        'identities': identities,
      };
}
