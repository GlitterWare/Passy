// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentCard _$PaymentCardFromJson(Map<String, dynamic> json) => PaymentCard(
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
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PaymentCardToJson(PaymentCard instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'cardNumber': instance.cardNumber,
      'cardholderName': instance.cardholderName,
      'cvv': instance.cvv,
      'exp': instance.exp,
      'customFields': instance.customFields.map((e) => e.toJson()).toList(),
      'additionalInfo': instance.additionalInfo,
      'tags': instance.tags,
    };
