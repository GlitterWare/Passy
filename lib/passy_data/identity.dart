import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'custom_field.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

class IdentitiesFile extends EncryptedJsonFile<DatedEntries<Identity>> {
  IdentitiesFile._(File file, Encrypter encrypter,
      {required DatedEntries<Identity> value})
      : super(file, encrypter, value: value);

  factory IdentitiesFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return IdentitiesFile._(file, encrypter,
          value: DatedEntries<Identity>.fromJson(
              decrypt(file.readAsStringSync(), encrypter: encrypter)));
    }
    IdentitiesFile _file =
        IdentitiesFile._(file, encrypter, value: DatedEntries<Identity>());
    _file.saveSync();
    return _file;
  }
}

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

enum Title { mr, mrs, miss, other }
enum Gender { male, female, other }

class Identity extends DatedEntry<Identity> {
  String nickname;
  Title title;
  String firstName;
  String middleName;
  String lastName;
  Gender gender;
  String email;
  String number;
  String firstAddressLine;
  String secondAddressLine;
  String zipCode;
  String city;
  String country;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  @override
  int compareTo(Identity other) => nickname.compareTo(other.nickname);

  factory Identity.fromJson(Map<String, dynamic> json) => Identity._(
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
        'title': _$TitleEnumMap[title],
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': _$GenderEnumMap[gender],
        'email': email,
        'number': number,
        'firstAddressLine': firstAddressLine,
        'secondAddressLine': secondAddressLine,
        'zipCode': zipCode,
        'city': city,
        'country': country,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'creationDate': creationDate.toIso8601String(),
      };

  Identity._({
    required this.nickname,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.number,
    required this.firstAddressLine,
    required this.secondAddressLine,
    required this.zipCode,
    required this.city,
    required this.country,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
    required DateTime creationDate,
  }) : super(creationDate);

  Identity({
    required this.nickname,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.number,
    required this.firstAddressLine,
    required this.secondAddressLine,
    required this.zipCode,
    required this.city,
    required this.country,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
  }) : super(DateTime.now().toUtc());
}
