import 'package:passy/passy/dated_entry.dart';

import 'custom_field.dart';

class Password extends DatedEntry<Password> {
  String nickname;
  String iconName;
  String username;
  String password;
  String website;
  String tfaSecret;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  @override
  int compareTo(Password other) => nickname.compareTo(other.nickname);

  factory Password.fromJson(Map<String, dynamic> json) => Password._(
        nickname: json['nickname'] as String,
        iconName: json['iconName'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        website: json['website'] as String,
        tfaSecret: json['tfaSecret'] as String,
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
            DateTime.tryParse(json['creationDate']) ?? DateTime.now().toUtc(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nickname': nickname,
        'iconName': iconName,
        'username': username,
        'password': password,
        'website': website,
        'tfaSecret': tfaSecret,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'creationDate': creationDate.toIso8601String(),
      };

  Password._({
    required this.nickname,
    required this.iconName,
    required this.username,
    required this.password,
    required this.website,
    required this.tfaSecret,
    required this.customFields,
    required this.additionalInfo,
    required this.tags,
    required DateTime creationDate,
  }) : super(creationDate);

  Password({
    this.nickname = '',
    this.iconName = '',
    this.username = '',
    this.password = '',
    this.website = '',
    this.tfaSecret = '',
    this.customFields = const [],
    this.additionalInfo = '',
    this.tags = const [],
  }) : super(DateTime.now().toUtc());
}
