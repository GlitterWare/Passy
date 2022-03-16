import 'package:json_annotation/json_annotation.dart';

import 'custom_field.dart';

part 'payment_card.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentCard {
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  PaymentCard({
    required this.nickname,
    required this.cardNumber,
    required this.cardholderName,
    required this.cvv,
    required this.exp,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) =>
      _$PaymentCardFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentCardToJson(this);
}
