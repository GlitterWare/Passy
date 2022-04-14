import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef Passwords = PassyEntries<Password>;

typedef PasswordsFile = PassyEntriesFile<Password>;

class Password extends PassyEntry<Password> {
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
        customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] as String,
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Password.fromCSV(List csv)
      : nickname = csv[1] ?? '',
        iconName = csv[2] ?? '',
        username = csv[3] ?? '',
        email = csv[4] ?? '',
        password = csv[5] ?? '',
        tfaSecret = csv[6] ?? '',
        website = csv[7] ?? '',
        customFields = (csv[8] as List<dynamic>?)
                ?.map((e) => CustomField.fromCSV(e))
                .toList() ??
            [],
        additionalInfo = csv[9] as String,
        tags = (csv[10] as List?)?.map((e) => e as String).toList() ?? [],
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

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
  List toCSV() => [
        key,
        nickname,
        iconName,
        username,
        email,
        password,
        tfaSecret,
        website,
        customFields.map((e) => e.toCSV()).toList(),
        additionalInfo,
        tags,
      ];
}
