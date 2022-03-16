// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_hello.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inside _$InsideFromJson(Map<String, dynamic> json) =>
    Inside()..b = json['b'] as int;

Map<String, dynamic> _$InsideToJson(Inside instance) => <String, dynamic>{
      'b': instance.b,
    };

Test _$TestFromJson(Map<String, dynamic> json) => Test()
  ..a = json['a'] as int
  ..inside = Inside.fromJson(json['inside'] as Map<String, dynamic>);

Map<String, dynamic> _$TestToJson(Test instance) => <String, dynamic>{
      'a': instance.a,
      'inside': instance.inside.toJson(),
    };
