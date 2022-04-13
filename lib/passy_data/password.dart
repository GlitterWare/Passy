import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef Passwords = PassyEntries<Password>;

typedef PasswordsFile = PassyEntriesFile<Password>;

class Password extends PassyEntry<Password> {
  static const csvSchema = {
    'key': 1,
    'nickname': 2,
    'iconName': 3,
    'username': 4,
    'email': 5,
    'password': 6,
    'tfaSecret': 7,
    'website': 8,
    'additionalInfo': 9
  };

  String nickname;
  String iconName;
  String username;
  String email;
  String password;
  String tfaSecret;
  String website;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  Password._({
    required String key,
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfaSecret = '',
    this.website = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(key);

  Password({
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfaSecret = '',
    this.website = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  Password.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        iconName = json['iconName'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        tfaSecret = json['tfaSecret'] ?? '',
        website = json['website'] ?? '',
        customFields = (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] as String,
        tags = (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  factory Password.fromCSV(
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> schemas = const {
      'password': csvSchema,
      'customField': CustomField.csvSchema,
    },
  }) {
    Map<String, int> _objectSchema = schemas['password'] ?? csvSchema;
    Map<String, int> _customFieldSchema =
        schemas['customField'] ?? CustomField.csvSchema;

    Password? _object;
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'password':
          _object = Password._(
            key: entry[_objectSchema['key']!],
            nickname: entry[_objectSchema['nickname']!],
            iconName: entry[_objectSchema['iconName']!],
            username: entry[_objectSchema['username']!],
            email: entry[_objectSchema['email']!],
            password: entry[_objectSchema['password']!],
            tfaSecret: entry[_objectSchema['tfaSecret']!],
            website: entry[_objectSchema['website']!],
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
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'email': email,
        'password': password,
        'tfaSecret': tfaSecret,
        'website': website,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
      };

  @override
  List<List> toCSV() => jsonToCSV(toJson());
}
