import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_form_entry.dart';

typedef Passwords = PassyEntries<Password>;

typedef PasswordsFile = PassyEntriesFile<Password>;

class Password extends PassyFormEntry<Password> {
  static const csvTemplate = {
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
  String additionalInfo;

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
  }) : super(
          key: key,
          customFields: customFields,
          tags: tags,
        );

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
  }) : super(
          key: DateTime.now().toUtc().toIso8601String(),
          customFields: customFields,
          tags: tags,
        );

  Password.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        iconName = json['iconName'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        tfaSecret = json['tfaSecret'] ?? '',
        website = json['website'] ?? '',
        additionalInfo = json['additionalInfo'] as String,
        super(
          key: json['key'] ?? DateTime.now().toUtc().toIso8601String(),
          customFields: (json['customFields'] as List<dynamic>?)
              ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList(),
          tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
        );

  factory Password.fromCSV(
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> templates = const {},
  }) {
    Map<String, int> _passwordTemplate = templates['password'] ?? csvTemplate;
    Map<String, int> _customFieldTemplate =
        templates['customField'] ?? CustomField.csvTemplate;
    Password? _password;
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'password':
          _password = Password._(
            key: entry[_passwordTemplate['key']!],
            nickname: entry[_passwordTemplate['nickname']!],
            iconName: entry[_passwordTemplate['iconName']!],
            username: entry[_passwordTemplate['username']!],
            email: entry[_passwordTemplate['email']!],
            password: entry[_passwordTemplate['password']!],
            tfaSecret: entry[_passwordTemplate['tfaSecret']!],
            website: entry[_passwordTemplate['website']!],
            additionalInfo: entry[_passwordTemplate['additionalInfo']!],
          );
          break;
        case 'customFields':
          _customFields
              .add(CustomField.fromCSV(entry, template: _customFieldTemplate));
          break;
        case 'tags':
          for (int i = 1; i != entry.length; i++) {
            _tags.add(entry[i]);
          }
          break;
      }
    }

    _password!.customFields = _customFields;
    _password.tags = _tags;
    return _password;
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
  List<List<dynamic>> toCSV() =>
      passyFormEntryToCSV(this, template: csvTemplate);
}
