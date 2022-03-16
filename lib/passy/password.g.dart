// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Password _$PasswordFromJson(Map<String, dynamic> json) => Password(
      nickname: json['nickname'] as String,
      icon: json['icon'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      website: json['website'] as String,
      tfaSecret: json['tfaSecret'] as String,
      customFields: (json['customFields'] as List<dynamic>?)
              ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      additionalInfo: json['additionalInfo'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PasswordToJson(Password instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'icon': instance.icon,
      'username': instance.username,
      'password': instance.password,
      'website': instance.website,
      'tfaSecret': instance.tfaSecret,
      'customFields': instance.customFields.map((e) => e.toJson()).toList(),
      'additionalInfo': instance.additionalInfo,
      'tags': instance.tags,
    };
