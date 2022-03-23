import 'package:json_annotation/json_annotation.dart';

import 'custom_field.dart';

part 'password.g.dart';

@JsonSerializable(explicitToJson: true)
class Password {
  String nickname;
  String icon;
  String username;
  String password;
  String website;
  String tfaSecret;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  Password({
    this.nickname = '',
    this.icon = '',
    this.username = '',
    this.password = '',
    this.website = '',
    this.tfaSecret = '',
    this.customFields = const [],
    this.additionalInfo = '',
    this.tags = const [],
  });

  factory Password.fromJson(Map<String, dynamic> json) =>
      _$PasswordFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordToJson(this);
}
