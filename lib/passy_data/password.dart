import 'custom_field.dart';
import 'encrypted_csv_file.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'tfa.dart';

typedef Passwords = PassyEntries<Password>;

typedef PasswordsFile = EncryptedCSVFile<Passwords>;

class Password extends PassyEntry<Password> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String iconName;
  String username;
  String email;
  String password;
  TFA? tfa;
  String website;

  Password({
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.tfa,
    this.website = '',
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  Password.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] as String,
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        iconName = json['iconName'] ?? '',
        username = json['username'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        tfa = json['tfa'] != null ? TFA.fromJson(json['tfa']) : null,
        website = json['website'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Password.fromCSV(List csv)
      : customFields = (csv[1] as List<dynamic>?)
                ?.map((e) => CustomField.fromCSV(e))
                .toList() ??
            [],
        additionalInfo = csv[2] as String,
        tags = (csv[3] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        iconName = csv[5] ?? '',
        username = csv[6] ?? '',
        email = csv[7] ?? '',
        password = csv[8] ?? '',
        tfa = csv[9].isNotEmpty ? TFA.fromCSV(csv[9][0]) : null,
        website = csv[10] ?? '',
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'email': email,
        'password': password,
        'tfa': tfa?.toJson(),
        'website': website,
      };

  @override
  List<List> toCSV() => [
        [
          key,
          customFields.map((e) => e.toCSV()).toList(),
          additionalInfo,
          tags,
          nickname,
          iconName,
          username,
          email,
          password,
          tfa?.toCSV() ?? [],
          website,
        ]
      ];
}
