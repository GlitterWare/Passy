import 'package:json_annotation/json_annotation.dart';

import 'custom_field.dart';

part 'identity.g.dart';

enum Title { mr, mrs, miss, other }
enum Gender { male, female, other }

@JsonSerializable(explicitToJson: true)
class Identity {
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
    required this.nickname,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.number,
    required this.firstAddressLine,
    required this.secondAddressLine,
    required this.zipCode,
    required this.city,
    required this.country,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
  });

  factory Identity.fromJson(Map<String, dynamic> json) =>
      _$IdentityFromJson(json);
  Map<String, dynamic> toJson() => _$IdentityToJson(this);
}
