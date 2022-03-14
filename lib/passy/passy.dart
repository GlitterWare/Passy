import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

enum FieldType { text, password, date, number }
enum Title { mr, mrs, miss, other }
enum Gender { male, female, other }
enum RecordType { password, paymentCard, secureNote, idCard, identity }

class CustomField {
  FieldType fieldType;
  String value = '';
  bool private = false;

  Map toJson() => {
        'fieldType': fieldType.toString(),
        'value': value,
        'private': private,
      };

  CustomField(this.fieldType);
}

class Account {
  Color color = Colors.purple;

  /// SHA512 encrypted password
  late String password;

  /// AES encrypted account data
  late String data;

  Map toJson() => {
        'password': password,
        'data': data,
      };

  Account(String password) {
    this.password = sha512.convert(utf8.encode(password)).toString();
    data = encrypt.Encrypter(
            encrypt.AES(encrypt.Key.fromUtf8(password).stretch(32)))
        .encrypt(
          jsonEncode(AccountData()),
          iv: encrypt.IV.fromLength(16),
        )
        .base16;
  }
}

class Password {
  String nickname = '';
  String username = '';
  String password = '';
  String website = '';
  String tfaSecret = '';
  List<CustomField> customFields = [];
  String additionalInfo = '';
  List<String> tags = [];
  late DateTime dateCreated;
  late DateTime dateModified;

  Map toJson() => {
        'nickname': nickname,
        'username': username,
        'password': password,
        'website': website,
        'tfaSecret': tfaSecret,
        'customFields': customFields,
        'additionalInfo': additionalInfo,
        'tags': tags,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateCreated.microsecondsSinceEpoch,
      };

  Password() {
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
  }
}

class PaymentCard {
  String nickname = '';
  String cardNumber = '';
  String cardholderName = '';
  String cvv = '';
  String exp = '';
  List<CustomField> customFields = [];
  String additionalInfo = '';
  List<String> tags = [];
  late DateTime dateCreated;
  late DateTime dateModified;

  Map toJson() => {
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
        'customFields': customFields,
        'additionalInfo': additionalInfo,
        'tags': tags,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
      };

  PaymentCard() {
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
  }
}

class Note {
  String title = '';
  String note = '';
  late DateTime dateCreated;
  late DateTime dateModified;

  Map toJson() => {
        'title': title,
        'note': note,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
      };

  Note() {
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
  }
}

class IDCard {
  String nickname = '';
  List<Uint8List> pictures = [];
  String type = '';
  String idNumber = '';
  String name = '';
  String issDate = '';
  String expDate = '';
  String country = '';
  List<CustomField> customFields = [];
  String additionalInfo = '';
  List<String> tags = [];
  late DateTime dateCreated;
  late DateTime dateModified;

  Map toJson() => {
        'nickname': nickname,
        'type': type,
        'idNumber': idNumber,
        'name': name,
        'issDate': issDate,
        'expDate': expDate,
        'country': country,
        'customFields': customFields,
        'additionalInfo': additionalInfo,
        'tags': tags,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
      };

  IDCard() {
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
  }
}

class Identity {
  String nickname = '';
  Title title = Title.mr;
  String firstName = '';
  String middleName = '';
  String lastName = '';
  Gender gender = Gender.male;
  String email = '';
  String number = '';
  String firstAddressLine = '';
  String secondAddressLine = '';
  String zipCode = '';
  String city = '';
  String country = '';
  List<CustomField> customFields = [];
  String additionalInfo = '';
  List<String> tags = [];
  late DateTime dateCreated;
  late DateTime dateModified;

  Map toJson() => {
        'nickname': nickname,
        'title': title.toString(),
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': gender.toString(),
        'email': email,
        'number': number,
        'firstAddressLine': firstAddressLine,
        'secondAddressLine': secondAddressLine,
        'zipCode': zipCode,
        'city': city,
        'country': country,
        'customFields': customFields,
        'additionalInfo': additionalInfo,
        'tags': tags,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
      };
}

class AccountData {
  List<Password> passwords = [];
  List<PaymentCard> paymentCards = [];
  List<Note> notes = [];
  List<IDCard> idCards = [];
  List<Identity> identities = [];
  late DateTime dateCreated;
  late DateTime dateModified;
  late DateTime dateRestored;

  Map toJson() => {
        'passwords': passwords,
        'paymentCards': paymentCards,
        'secureNotes': notes,
        'idCards': idCards,
        'identities': identities,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
        'dateRestored': dateRestored.microsecondsSinceEpoch,
      };

  AccountData() {
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
    dateRestored = _now;
  }
}
