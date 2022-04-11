import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'encrypted_json_file.dart';

typedef Identities = PassyEntries<Identity>;

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

enum Title { mr, mrs, miss, other, error }

Title titleFromName(String name) {
  switch (name) {
    case 'mr':
      return Title.mr;
    case 'mrs':
      return Title.mrs;
    case 'miss':
      return Title.miss;
    case 'other':
      return Title.other;
    default:
      return Title.error;
  }
}

enum Gender { male, female, other, error }

Gender genderFromName(String name) {
  switch (name) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'other':
      return Gender.other;
    default:
      return Gender.error;
  }
}

class Identity extends PassyEntry<Identity> {
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
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  Identity.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        title = titleFromName(json['title'] ?? 'mr'),
        firstName = json['firstName'] ?? '',
        middleName = json['middleName'] ?? '',
        lastName = json['lastName'] ?? '',
        gender = genderFromName(json['gender'] ?? 'male'),
        email = json['email'] ?? '',
        number = json['number'] ?? '',
        firstAddressLine = json['firstAddressLine'] ?? '',
        secondAddressLine = json['secondAddressLine'] ?? '',
        zipCode = json['zipCode'] ?? '',
        city = json['city'] ?? '',
        country = json['country'] ?? '',
        customFields = (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        super(json['creationDate'] ?? DateTime.now().toUtc().toIso8601String());

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'title': title.name,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': gender.name,
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
        'creationDate': key,
      };

  @override
  int compareTo(Identity other) => nickname.compareTo(other.nickname);
}
