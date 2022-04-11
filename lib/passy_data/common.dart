import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/error_entry.dart';
import 'package:passy/passy_data/payment_card.dart';

import 'dated_entry.dart';
import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';

const String passyVersion = '0.0.0';

final Random random = Random.secure();

enum EntryType {
  password,
  passwordIcon,
  paymentCard,
  note,
  idCard,
  identity,
  error
}

EntryType entryTypeFromName(String name) {
  switch (name) {
    case 'password':
      return EntryType.password;
    case 'passwordIcon':
      return EntryType.passwordIcon;
    case 'paymentCard':
      return EntryType.paymentCard;
    case 'note':
      return EntryType.note;
    case 'idCard':
      return EntryType.idCard;
    case 'identity':
      return EntryType.identity;
    default:
      return EntryType.error;
  }
}

EntryType entryTypeFromType(Type type) {
  switch (type) {
    case Password:
      return EntryType.password;
    case PaymentCard:
      return EntryType.paymentCard;
    case Note:
      return EntryType.note;
    case IDCard:
      return EntryType.idCard;
    case Identity:
      return EntryType.identity;
    default:
      return EntryType.error;
  }
}

DatedEntry fromJson(EntryType entryType, Map<String, dynamic> json) {
  switch (entryType) {
    case EntryType.password:
      return Password.fromJson(json);
    case EntryType.paymentCard:
      return PaymentCard.fromJson(json);
    case EntryType.note:
      return Note.fromJson(json);
    case EntryType.idCard:
      return IDCard.fromJson(json);
    case EntryType.identity:
      return Identity.fromJson(json);
    default:
      return ErrorEntry();
  }
}

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
