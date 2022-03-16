import 'package:json_annotation/json_annotation.dart';

import 'custom_field.dart';

part 'id_card.g.dart';

@JsonSerializable(explicitToJson: true)
class IDCard {
  String nickname;
  List<String> pictures;
  String type;
  String idNumber;
  String name;
  String issDate;
  String expDate;
  String country;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  IDCard({
    required this.nickname,
    required this.pictures,
    required this.type,
    required this.idNumber,
    required this.name,
    required this.issDate,
    required this.expDate,
    required this.country,
    this.customFields = const [],
    required this.additionalInfo,
    this.tags = const [],
  });

  factory IDCard.fromJson(Map<String, dynamic> json) => _$IDCardFromJson(json);
  Map<String, dynamic> toJson() => _$IDCardToJson(this);
}
