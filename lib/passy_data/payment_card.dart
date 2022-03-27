import 'dated_entry.dart';

import 'custom_field.dart';

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
        nickname: json['nickname'] as String,
        cardNumber: json['cardNumber'] as String,
        cardholderName: json['cardholderName'] as String,
        cvv: json['cvv'] as String,
        exp: json['exp'] as String,
        customFields: (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        additionalInfo: json['additionalInfo'] as String,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        creationDate:
            DateTime.tryParse(json['creationDate']) ?? DateTime.now().toUtc(),
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
        'creationDate': creationDate.toIso8601String(),
      };

  PaymentCard._({
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.cvv,
    required this.exp,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
    required DateTime creationDate,
  }) : super(creationDate);

  PaymentCard({
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.cvv,
    required this.exp,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
  }) : super(DateTime.now().toUtc());
}
