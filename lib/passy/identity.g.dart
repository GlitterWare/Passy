// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Identity _$IdentityFromJson(Map<String, dynamic> json) => Identity(
      nickname: json['nickname'] as String,
      title: $enumDecode(_$TitleEnumMap, json['title']),
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      email: json['email'] as String,
      number: json['number'] as String,
      firstAddressLine: json['firstAddressLine'] as String,
      secondAddressLine: json['secondAddressLine'] as String,
      zipCode: json['zipCode'] as String,
      city: json['city'] as String,
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

Map<String, dynamic> _$IdentityToJson(Identity instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'title': _$TitleEnumMap[instance.title],
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'gender': _$GenderEnumMap[instance.gender],
      'email': instance.email,
      'number': instance.number,
      'firstAddressLine': instance.firstAddressLine,
      'secondAddressLine': instance.secondAddressLine,
      'zipCode': instance.zipCode,
      'city': instance.city,
      'country': instance.country,
      'customFields': instance.customFields.map((e) => e.toJson()).toList(),
      'additionalInfo': instance.additionalInfo,
      'tags': instance.tags,
    };

const _$TitleEnumMap = {
  Title.mr: 'mr',
  Title.mrs: 'mrs',
  Title.miss: 'miss',
  Title.other: 'other',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};
