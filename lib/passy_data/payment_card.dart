import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'custom_field.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

typedef PaymentCards = DatedEntries<PaymentCard>;

class PaymentCardsFile extends EncryptedJsonFile<PaymentCards> {
  PaymentCardsFile._(File file, Encrypter encrypter,
      {required PaymentCards value})
      : super(file, encrypter, value: value);

  factory PaymentCardsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return PaymentCardsFile._(file, encrypter,
          value: PaymentCards.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    file.createSync(recursive: true);
    PaymentCardsFile _file =
        PaymentCardsFile._(file, encrypter, value: PaymentCards());
    _file.saveSync();
    return _file;
  }
}

class PaymentCard extends DatedEntry<PaymentCard> {
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  @override
  int compareTo(PaymentCard other) => nickname.compareTo(other.nickname);

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard._(
        nickname: json['nickname'] ?? '',
        cardNumber: json['cardNumber'] ?? '',
        cardholderName: json['cardholderName'] ?? '',
        cvv: json['cvv'] ?? '',
        exp: json['exp'] ?? '',
        customFields: (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo: json['additionalInfo'] ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        creationDate:
            json['creationDate'] ?? DateTime.now().toUtc().toIso8601String(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'creationDate': creationDate,
      };

  PaymentCard._({
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.cvv,
    required this.exp,
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
    required String creationDate,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(creationDate);

  PaymentCard({
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.cvv,
    required this.exp,
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());
}
