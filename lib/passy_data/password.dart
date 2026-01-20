import 'package:passy/passy_data/entry_meta.dart';

import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_encrypted_csv_file.dart';
import 'passy_entry.dart';
import 'passy_kdbx_entry.dart';
import 'tfa.dart';

typedef Passwords = PassyEntries<Password>;

typedef PasswordsFile = PassyEntriesEncryptedCSVFile<Password>;

class PasswordMeta extends EntryMeta {
  final List<String> tags;
  final String nickname;
  final String username;
  List<String> websites;

  PasswordMeta(
      {required String key,
      required this.tags,
      required this.nickname,
      required this.username,
      required this.websites})
      : super(key);

  @override
  toJson() => {
        'key': key,
        'tags': tags,
        'nickname': nickname,
        'username': username,
        'website': websites.join('\n'),
      };
}

class Password extends PassyEntry<Password> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String iconName;
  String username;
  String email;
  String password;
  List<String> oldPasswords;
  TFA? tfa;
  List<String> websites;
  List<String> attachments;

  Password({
    String? key,
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    List<String>? oldPasswords,
    this.tfa,
    List<String>? websites,
    List<String>? attachments,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        oldPasswords = oldPasswords ?? [],
        websites = websites ?? [],
        attachments = attachments ?? [],
        super(key ?? DateTime.now().toUtc().toIso8601String());

  @override
  PasswordMeta get metadata => PasswordMeta(
      key: key,
      tags: tags.toList(),
      nickname: nickname,
      username: username,
      websites: websites);

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
        oldPasswords = (json['oldPasswords'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        tfa = json['tfa'] != null ? TFA.fromJson(json['tfa']) : null,
        websites = (json['website'] as String?)?.split('\n') ?? [],
        attachments = (json['attachments'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  Password._fromCSV(List csv)
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
        password = '',
        oldPasswords = csv[8].split('\n') ?? [''],
        tfa = csv[9].isNotEmpty ? TFA.fromCSV(csv[9]) : null,
        websites = (csv[10] as String?)?.split('\n') ?? [],
        attachments =
            (csv[11] as List<dynamic>).map((e) => e.toString()).toList(),
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String()) {
    password = oldPasswords[0];
    oldPasswords.removeAt(0);
  }

  factory Password.fromCSV(List csv) {
    if (csv.length == 11) csv.add([]);
    return Password._fromCSV(csv);
  }

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
        'oldPasswords': oldPasswords,
        'tfa': tfa?.toJson(),
        'website': websites.join('\n'),
        'attachments': attachments,
      };

  @override
  List toCSV() {
    return [
      key,
      customFields.map((e) => e.toCSV()).toList(),
      additionalInfo,
      tags,
      nickname,
      iconName,
      username,
      email,
      (oldPasswords.toList()..insert(0, password)).join('\n'),
      tfa?.toCSV() ?? [],
      websites.join('\n'),
      attachments,
    ];
  }

  @override
  PassyKdbxEntry toKdbx() {
    List<CustomField> websiteFields = [];
    if (websites.length > 1) {
      for (int i = 1; i != websites.length; i++) {
        websiteFields.add(CustomField(
          title: 'Website ${i + 1}',
          value: websites[i],
        ));
      }
    }
    return PassyKdbxEntry(
      title: nickname,
      username: username.isEmpty ? email : username,
      password: password,
      url: websites[0],
      otp: tfa?.secret,
      customFields: [
        if (username.isNotEmpty && email.isNotEmpty)
          CustomField(title: 'Email', value: email),
        ...websiteFields,
        ...customFields,
        if (tfa != null)
          CustomField(
              obscured: true,
              title: 'TFA info',
              value:
                  'Algorithm: ${tfa?.algorithm} ; Length: ${tfa?.length} ; Interval: ${tfa?.interval} ; Is Google: ${tfa?.isGoogle}'),
        if (additionalInfo.isNotEmpty)
          CustomField(title: 'Additional info', value: additionalInfo),
      ],
    );
  }
}
