import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/passy_kdbx_entry.dart';

import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_encrypted_csv_file.dart';
import 'passy_entry.dart';

typedef Identities = PassyEntries<Identity>;

typedef IdentitiesFile = PassyEntriesEncryptedCSVFile<Identity>;

enum Title { mx, mr, mrs, miss, other }

Title? titleFromName(String name) {
  switch (name) {
    case 'mx':
      return Title.mx;
    case 'mr':
      return Title.mr;
    case 'mrs':
      return Title.mrs;
    case 'miss':
      return Title.miss;
    case 'other':
      return Title.other;
  }
  return null;
}

enum Gender { notSpecified, male, female, other }

Gender? genderFromName(String name) {
  switch (name) {
    case 'notSpecified':
      return Gender.notSpecified;
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'other':
      return Gender.other;
  }
  return null;
}

class IdentityMeta extends EntryMeta {
  final List<String> tags;
  final String nickname;
  final String firstAddressLine;

  IdentityMeta(
      {required String key,
      required this.tags,
      required this.nickname,
      required this.firstAddressLine})
      : super(key);

  @override
  toJson() => {
        'key': key,
        'tags': tags,
        'nickname': nickname,
        'firstAddressLine': firstAddressLine,
      };
}

class Identity extends PassyEntry<Identity> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
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
  List<String> attachments;

  Identity({
    String? key,
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.title = Title.mx,
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.gender = Gender.notSpecified,
    this.email = '',
    this.number = '',
    this.firstAddressLine = '',
    this.secondAddressLine = '',
    this.zipCode = '',
    this.city = '',
    this.country = '',
    List<String>? attachments,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        attachments = attachments ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  IdentityMeta get metadata => IdentityMeta(
      key: key,
      tags: tags.toList(),
      nickname: nickname,
      firstAddressLine: firstAddressLine);

  Identity.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        title = titleFromName(json['title']) ?? Title.mx,
        firstName = json['firstName'] ?? '',
        middleName = json['middleName'] ?? '',
        lastName = json['lastName'] ?? '',
        gender = genderFromName(json['gender']) ?? Gender.notSpecified,
        email = json['email'] ?? '',
        number = json['number'] ?? '',
        firstAddressLine = json['firstAddressLine'] ?? '',
        secondAddressLine = json['secondAddressLine'] ?? '',
        zipCode = json['zipCode'] ?? '',
        city = json['city'] ?? '',
        country = json['country'] ?? '',
        attachments = json['attachments'] == null
            ? []
            : (json['attachments'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Identity._fromCSV(List csv)
      : customFields =
            (csv[1] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[2] ?? '',
        tags = (csv[3] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        title = titleFromName(csv[5]) ?? Title.mx,
        firstName = csv[6] ?? '',
        middleName = csv[7] ?? '',
        lastName = csv[8] ?? '',
        gender = genderFromName(csv[9]) ?? Gender.notSpecified,
        email = csv[10] ?? '',
        number = csv[11] ?? '',
        firstAddressLine = csv[12] ?? '',
        secondAddressLine = csv[13] ?? '',
        zipCode = csv[14] ?? '',
        city = csv[15] ?? '',
        country = csv[16] ?? '',
        attachments =
            (csv[17] as List<dynamic>).map((e) => e.toString()).toList(),
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  factory Identity.fromCSV(List csv) {
    if (csv.length == 17) csv.add([]);
    return Identity._fromCSV(csv);
  }

  @override
  int compareTo(Identity other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
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
        'attachments': attachments,
      };

  @override
  List toCSV() => [
        key,
        customFields.map((e) => e.toCSV()).toList(),
        additionalInfo,
        tags,
        nickname,
        title.name,
        firstName,
        middleName,
        lastName,
        gender.name,
        email,
        number,
        firstAddressLine,
        secondAddressLine,
        zipCode,
        city,
        country,
        attachments,
      ];

  @override
  PassyKdbxEntry toKdbx() {
    return PassyKdbxEntry(
      title: nickname,
      customFields: [
        if (title.name.isNotEmpty)
          CustomField(title: 'Personal title', value: title.name),
        if (firstName.isNotEmpty)
          CustomField(title: 'First name', value: firstName),
        if (middleName.isNotEmpty)
          CustomField(title: 'Middle name', value: middleName),
        if (lastName.isNotEmpty)
          CustomField(title: 'Last name', value: lastName),
        if (gender.name.isNotEmpty)
          CustomField(title: 'Gender', value: gender.name),
        if (email.isNotEmpty) CustomField(title: 'Email', value: email),
        if (number.isNotEmpty)
          CustomField(title: 'Phone number', value: number),
        if (firstAddressLine.isNotEmpty)
          CustomField(title: 'First address line', value: firstAddressLine),
        if (secondAddressLine.isNotEmpty)
          CustomField(title: 'Second address line', value: secondAddressLine),
        if (zipCode.isNotEmpty) CustomField(title: 'Zip code', value: zipCode),
        if (city.isNotEmpty) CustomField(title: 'City', value: city),
        if (country.isNotEmpty) CustomField(title: 'Country', value: country),
        ...customFields,
        if (additionalInfo.isNotEmpty)
          CustomField(title: 'Additional info', value: additionalInfo),
      ],
    );
  }
}
