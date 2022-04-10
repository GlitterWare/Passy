import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'dated_entry.dart';
import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

const String passyVersion = '0.0.0';

final Random random = Random.secure();

const Map<Type, DatedEntry Function(Map<String, dynamic> json)>
    fromJsonMethods = {
  Password: Password.fromJson,
  Note: Note.fromJson,
  PaymentCard: PaymentCard.fromJson,
  IDCard: IDCard.fromJson,
  Identity: Identity.fromJson,
};

enum EntryType { password, passwordIcon, paymentCard, note, idCard, identity }

const entryTypeToJson = {
  EntryType.password: 'password',
  EntryType.passwordIcon: 'passwordIcon',
  EntryType.paymentCard: 'paymentCard',
  EntryType.note: 'note',
  EntryType.idCard: 'idCard',
  EntryType.identity: 'identity',
};

const entryTypeFromJson = {
  'password': EntryType.password,
  'passwordIcon': EntryType.passwordIcon,
  'paymentCard': EntryType.paymentCard,
  'note': EntryType.note,
  'idCard': EntryType.idCard,
  'identity': EntryType.identity,
};

Encrypter getEncrypter(String password) {
  if (password.length > 32) {
    throw Exception('Password is longer than 32 characters');
  }
  int a = 32 - password.length;
  password += ' ' * a;
  return Encrypter(AES(Key.fromUtf8(password)));
}

Digest getHash(String value) => sha512.convert(utf8.encode(value));

String encrypt(String data, {required Encrypter encrypter}) => encrypter
    .encrypt(
      data,
      iv: IV.fromLength(16),
    )
    .base64;

String decrypt(String data, {required Encrypter encrypter}) =>
    encrypter.decrypt64(
      data,
      iv: IV.fromLength(16),
    );
