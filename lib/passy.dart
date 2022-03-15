import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

enum FieldType { text, password, date, number }
enum Title { mr, mrs, miss, other }
enum Gender { male, female, other }
enum EntryType { password, paymentCard, note, idCard, identity }

String getPasswordHash(String password) =>
    sha512.convert(utf8.encode(password)).toString();

String extendPassword(String password) {
  int a = 32 - password.length;
  password += ' ' * a;
  return password;
}

class CustomField {
  FieldType fieldType;
  String value = '';
  bool private = false;

  Map toJson() => {
        'fieldType': fieldType.toString(),
        'value': value,
        'private': private,
      };

  static CustomField reviver(Object? key, Object? value) {
    CustomField _customField = CustomField();
    return _customField;
  }

  CustomField({this.fieldType = FieldType.password});
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

  static Password reviver(Object? key, Object? value) {
    Password _password = Password(setTime: false);
    return _password;
  }

  Password({bool setTime = true}) {
    if (!setTime) return;
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

  static Note reviver(Object? key, Object? value) {
    Note _note = Note(setTime: false);
    return _note;
  }

  Note({bool setTime = true}) {
    if (!setTime) return;
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

  static PaymentCard reviver(Object? key, Object? value) {
    PaymentCard _paymentCard = PaymentCard(setTime: false);
    return _paymentCard;
  }

  PaymentCard({bool setTime = true}) {
    if (!setTime) return;
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

  static IDCard reviver(Object? key, Object? value) {
    IDCard _idCard = IDCard(setTime: false);
    return _idCard;
  }

  IDCard({bool setTime = true}) {
    if (!setTime) return;
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

  static Identity reviver(Object? key, Object? value) {
    Identity _identity = Identity(setTime: false);
    return _identity;
  }

  Identity({bool setTime = true}) {
    if (!setTime) return;
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
  }
}

class AccountData {
  List<Password> passwords = [];
  List<Note> notes = [];
  List<PaymentCard> paymentCards = [];
  List<IDCard> idCards = [];
  List<Identity> identities = [];
  late DateTime dateCreated;
  late DateTime dateModified;
  late DateTime dateRestored;

  String encrypt(String password) =>
      enc.Encrypter(enc.AES(enc.Key.fromUtf8(extendPassword(password)),
              mode: enc.AESMode.ctr, padding: null))
          .encrypt(
            jsonEncode(this),
            iv: enc.IV.fromLength(16),
          )
          .base16;

  static AccountData decrypt(String encrypted, String password) => jsonDecode(
      enc.Encrypter(enc.AES(enc.Key.fromUtf8(extendPassword(password)),
              mode: enc.AESMode.ctr, padding: null))
          .decrypt16(
        encrypted,
        iv: enc.IV.fromLength(16),
      ),
      reviver: AccountData.reviver);

  Map toJson() => {
        'passwords': passwords,
        'notes': notes,
        'paymentCards': paymentCards,
        'idCards': idCards,
        'identities': identities,
        'dateCreated': dateCreated.microsecondsSinceEpoch,
        'dateModified': dateModified.microsecondsSinceEpoch,
        'dateRestored': dateRestored.microsecondsSinceEpoch,
      };

  static AccountData reviver(Object? key, Object? value) {
    AccountData _accountData = AccountData(setTime: false);
    switch (key) {
      case 'passwords':
        for (String s in value as List<dynamic>) {
          _accountData.passwords.add(jsonDecode(s, reviver: Password.reviver));
        }
        break;
      case 'paymentCards':
        for (String s in value as List<dynamic>) {
          _accountData.paymentCards
              .add(jsonDecode(s, reviver: PaymentCard.reviver));
        }
        break;
      case 'notes':
        for (String s in value as List<dynamic>) {
          _accountData.notes.add(jsonDecode(s, reviver: Note.reviver));
        }
        break;
      case 'idCards':
        for (String s in value as List<dynamic>) {
          _accountData.idCards.add(jsonDecode(s, reviver: IDCard.reviver));
        }
        break;
      case 'identities':
        for (String s in value as List<dynamic>) {
          _accountData.identities.add(jsonDecode(s, reviver: Identity.reviver));
        }
        break;
      case 'dateCreated':
        _accountData.dateCreated =
            DateTime.fromMicrosecondsSinceEpoch(value as int);
        break;
      case 'dateModified':
        _accountData.dateModified =
            DateTime.fromMicrosecondsSinceEpoch(value as int);
        break;
      case 'dateRestored':
        _accountData.dateRestored =
            DateTime.fromMicrosecondsSinceEpoch(value as int);
        break;
    }
    return _accountData;
  }

  AccountData({bool setTime = true}) {
    if (!setTime) return;
    DateTime _now = DateTime.now().toUtc();
    dateCreated = _now;
    dateModified = _now;
    dateRestored = _now;
  }
}
