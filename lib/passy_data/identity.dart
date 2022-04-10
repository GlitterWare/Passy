import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'custom_field.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

typedef Identities = DatedEntries<Identity>;

class IdentitiesFile extends EncryptedJsonFile<Identities> {
  IdentitiesFile._(File file, Encrypter encrypter, {required Identities value})
      : super(file, encrypter, value: value);

  factory IdentitiesFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return IdentitiesFile._(file, encrypter,
          value: Identities.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    IdentitiesFile _file =
        IdentitiesFile._(file, encrypter, value: Identities());
    _file.saveSync();
    return _file;
  }
}

enum Title { mr, mrs, miss, other }

const titleToJson = {
  Title.mr: 'mr',
  Title.mrs: 'mrs',
  Title.miss: 'miss',
  Title.other: 'other',
};

const titleFromJson = {
  'mr': Title.mr,
  'mrs': Title.mrs,
  'miss': Title.miss,
  'other': Title.other,
};

enum Gender { male, female, other }

const genderToJson = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const genderFromJson = {
  'male': Gender.male,
  'female': Gender.female,
  'other': Gender.other,
};

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
        nickname: json['nickname'] ?? '',
        title: titleFromJson[json['title']] ?? Title.mr,
        firstName: json['firstName'] ?? '',
        middleName: json['middleName'] ?? '',
        lastName: json['lastName'] ?? '',
        gender: genderFromJson[json['gender']] ?? Gender.male,
        email: json['email'] ?? '',
        number: json['number'] ?? '',
        firstAddressLine: json['firstAddressLine'] ?? '',
        secondAddressLine: json['secondAddressLine'] ?? '',
        zipCode: json['zipCode'] ?? '',
        city: json['city'] ?? '',
        country: json['country'] ?? '',
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
            json['creationDate'] ?? DateTime.now().toUtc().toIso8601String(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'title': titleToJson[title],
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': genderToJson[gender],
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
        'creationDate': creationDate,
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
    required String creationDate,
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
  }) : super(DateTime.now().toUtc().toIso8601String());
}
