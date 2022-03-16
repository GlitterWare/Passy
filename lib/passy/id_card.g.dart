// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IDCard _$IDCardFromJson(Map<String, dynamic> json) => IDCard(
      nickname: json['nickname'] as String,
      pictures:
          (json['pictures'] as List<dynamic>).map((e) => e as String).toList(),
      type: json['type'] as String,
      idNumber: json['idNumber'] as String,
      name: json['name'] as String,
      issDate: json['issDate'] as String,
      expDate: json['expDate'] as String,
      country: json['country'] as String,
      customFields: (json['customFields'] as List<dynamic>?)
              ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      additionalInfo: json['additionalInfo'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$IDCardToJson(IDCard instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'pictures': instance.pictures,
      'type': instance.type,
      'idNumber': instance.idNumber,
      'name': instance.name,
      'issDate': instance.issDate,
      'expDate': instance.expDate,
      'country': instance.country,
      'customFields': instance.customFields.map((e) => e.toJson()).toList(),
      'additionalInfo': instance.additionalInfo,
      'tags': instance.tags,
    };
