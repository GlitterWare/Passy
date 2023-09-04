import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/passy_entries_encrypted_csv_file.dart';
import 'package:passy/passy_data/passy_kdbx_entry.dart';

import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef PaymentCards = PassyEntries<PaymentCard>;

typedef PaymentCardsFile = PassyEntriesEncryptedCSVFile<PaymentCard>;

class PaymentCardMeta extends EntryMeta {
  final List<String> tags;
  final String nickname;
  final String cardNumber;
  final String cardholderName;
  final String exp;

  PaymentCardMeta({
    required String key,
    required this.tags,
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.exp,
  }) : super(key);

  @override
  toJson() => {
        'key': key,
        'tags': tags,
        'nickname': nickname,
        'cardholderName': cardholderName,
      };
}

class PaymentCard extends PassyEntry<PaymentCard> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;

  PaymentCard({
    String? key,
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.cardNumber = '',
    this.cardholderName = '',
    this.cvv = '',
    this.exp = '',
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  PaymentCardMeta get metadata => PaymentCardMeta(
      key: key,
      tags: tags.toList(),
      nickname: nickname,
      cardNumber: cardNumber.length < 5
          ? cardNumber
          : cardNumber.replaceRange(4, null, '************'),
      cardholderName: cardholderName,
      exp: exp);

  PaymentCardMeta get uncensoredMetadata => PaymentCardMeta(
      key: key,
      tags: tags,
      nickname: nickname,
      cardNumber: cardNumber,
      cardholderName: cardholderName,
      exp: exp);

  PaymentCard.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        cardNumber = json['cardNumber'] ?? '',
        cardholderName = json['cardholderName'] ?? '',
        cvv = json['cvv'] ?? '',
        exp = json['exp'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  PaymentCard.fromCSV(List csv)
      : customFields =
            (csv[1] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[2] ?? '',
        tags = (csv[3] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        cardNumber = csv[5] ?? '',
        cardholderName = csv[6] ?? '',
        cvv = csv[7] ?? '',
        exp = csv[8] ?? '',
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(PaymentCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
      };

  @override
  List toCSV() => [
        key,
        customFields.map((e) => e.toCSV()).toList(),
        additionalInfo,
        tags,
        nickname,
        cardNumber,
        cardholderName,
        cvv,
        exp,
      ];

  @override
  PassyKdbxEntry toKdbx() {
    return PassyKdbxEntry(
      title: nickname,
      customFields: [
        if (cardNumber.isNotEmpty)
          CustomField(title: 'Card number', value: cardNumber, obscured: true),
        if (cardholderName.isNotEmpty)
          CustomField(title: 'Card holder name', value: cardholderName),
        if (cvv.isNotEmpty)
          CustomField(title: 'Name', value: cvv, obscured: true),
        if (exp.isNotEmpty) CustomField(title: 'Issue date', value: exp),
        ...customFields,
        if (additionalInfo.isNotEmpty)
          CustomField(title: 'Additional info', value: additionalInfo),
      ],
    );
  }
}
