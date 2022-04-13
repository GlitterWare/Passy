import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef Identities = PassyEntries<Identity>;

typedef IdentitiesFile = PassyEntriesFile<Identity>;

enum Title { mr, mrs, miss, other }

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
      throw Exception('Cannot convert String \'$name\' to Title');
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
      throw Exception('Cannot convert String \'$name\' to Gender');
  }
}

class Identity extends PassyEntry<Identity> {
  static const csvSchema = {
    'nickname': 1,
    'title': 2,
    'firstName': 3,
    'middleName': 4,
    'lastName': 5,
    'gender': 6,
    'email': 7,
    'number': 8,
    'firstAddressLine': 9,
    'secondAddressLine': 10,
    'zipCode': 11,
    'city': 12,
    'country': 13,
    'additionalInfo': 14,
  };

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

  Identity._({
    required String key,
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
        super(key);

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
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  factory Identity.fromCSV(List<List<dynamic>> csv,
      {Map<String, Map<String, int>> schemas = const {}}) {
    Map<String, int> _objectSchema = schemas['idCard'] ?? csvSchema;
    Map<String, int> _customFieldSchema =
        schemas['customField'] ?? CustomField.csvSchema;

    Identity? _object;
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'idCard':
          _object = Identity._(
            key: entry[_objectSchema['key']!],
            nickname: entry[_objectSchema['nickname']!],
            title: titleFromName(entry[_objectSchema['title']!]),
            firstName: entry[_objectSchema['firstName']!],
            middleName: entry[_objectSchema['middleName']!],
            lastName: entry[_objectSchema['lastName']!],
            gender: genderFromName(entry[_objectSchema['gender']!]),
            email: entry[_objectSchema['email']!],
            number: entry[_objectSchema['number']!],
            firstAddressLine: entry[_objectSchema['firstAddressLine']!],
            secondAddressLine: entry[_objectSchema['secondAddressLine']!],
            zipCode: entry[_objectSchema['zipCode']!],
            city: entry[_objectSchema['city']!],
            country: entry[_objectSchema['country']!],
            additionalInfo: entry[_objectSchema['additionalInfo']!],
          );
          break;
        case 'customFields':
          _customFields
              .add(CustomField.fromCSV(entry, csvSchema: _customFieldSchema));
          break;
        case 'tags':
          List<String> _entry = (entry as List<String>).toList()..removeAt(0);
          _tags.addAll(_entry);
          break;
      }
    }

    _object!
      ..customFields = _customFields
      ..tags = _tags;
    return _object;
  }

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
  List<List> toCSV() => jsonToCSV(toJson());
}
