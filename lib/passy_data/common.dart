import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'dated_entry.dart';
import 'id_card.dart';
import 'identity.dart';
import 'password.dart';
import 'payment_card.dart';

import 'note.dart';

const Map<Type, DatedEntry Function(Map<String, dynamic> json)>
    fromJsonMethods = {
  Password: Password.fromJson,
  Note: Note.fromJson,
  PaymentCard: PaymentCard.fromJson,
  IDCard: IDCard.fromJson,
  Identity: Identity.fromJson,
};

enum EntryType { password, paymentCard, note, idCard, identity }

Encrypter getEncrypter(String password) {
  if (password.length > 32) {
    throw Exception('Password is longer than 32 characters');
  }
  int a = 32 - password.length;
  password += ' ' * a;
  return Encrypter(AES(Key.fromUtf8(password)));
}

String getPasswordHash(String password) =>
    sha512.convert(utf8.encode(password)).toString();

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
