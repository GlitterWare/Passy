import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef Identities = PassyEntries<Identity>;

typedef IdentitiesFile = PassyEntriesFile<Identity>;

enum Title { mr, mrs, miss, other }

Title? titleFromName(String name) {
  switch (name) {
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

enum Gender { male, female, other, error }

Gender? genderFromName(String name) {
  switch (name) {
    case 'male':
      return Gender.male;
    case 'female':
      return Gender.female;
    case 'other':
      return Gender.other;
  }
  return null;
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
    this.nickname = '',
    this.title = Title.mr,
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.gender = Gender.male,
    this.email = '',
    this.number = '',
    this.firstAddressLine = '',
    this.secondAddressLine = '',
    this.zipCode = '',
    this.city = '',
    this.country = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  Identity.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        title = titleFromName(json['title']) ?? Title.mr,
        firstName = json['firstName'] ?? '',
        middleName = json['middleName'] ?? '',
        lastName = json['lastName'] ?? '',
        gender = genderFromName(json['gender']) ?? Gender.male,
        email = json['email'] ?? '',
        number = json['number'] ?? '',
        firstAddressLine = json['firstAddressLine'] ?? '',
        secondAddressLine = json['secondAddressLine'] ?? '',
        zipCode = json['zipCode'] ?? '',
        city = json['city'] ?? '',
        country = json['country'] ?? '',
        customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Identity.fromCSV(List csv)
      : nickname = csv[1] ?? '',
        title = titleFromName(csv[2]) ?? Title.mr,
        firstName = csv[3] ?? '',
        middleName = csv[4] ?? '',
        lastName = csv[5] ?? '',
        gender = genderFromName(csv[6]) ?? Gender.male,
        email = csv[7] ?? '',
        number = csv[8] ?? '',
        firstAddressLine = csv[9] ?? '',
        secondAddressLine = csv[10] ?? '',
        zipCode = csv[11] ?? '',
        city = csv[12] ?? '',
        country = csv[13] ?? '',
        customFields =
            (csv[14] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[15] ?? '',
        tags = (csv[16] as List?)?.map((e) => e as String).toList() ?? [],
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(Identity other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
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
      };

  @override
  List toCSV() => [
        key,
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
        customFields.map((e) => e.toCSV()),
        additionalInfo,
        tags,
      ];
}
