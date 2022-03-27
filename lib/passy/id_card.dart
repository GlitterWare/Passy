import 'package:passy/passy/dated_entry.dart';

import 'custom_field.dart';

class IDCard extends DatedEntry<IDCard> {
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

  @override
  int compareTo(IDCard other) => nickname.compareTo(other.nickname);

  factory IDCard.fromJson(Map<String, dynamic> json) => IDCard._(
        nickname: json['nickname'] as String,
        pictures: (json['pictures'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        type: json['type'] as String,
        idNumber: json['idNumber'] as String,
        name: json['name'] as String,
        issDate: json['issDate'] as String,
        expDate: json['expDate'] as String,
        country: json['country'] as String,
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
        'pictures': pictures,
        'type': type,
        'idNumber': idNumber,
        'name': name,
        'issDate': issDate,
        'expDate': expDate,
        'country': country,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'creationDate': creationDate.toIso8601String(),
      };

  IDCard._({
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
    required DateTime creationDate,
  }) : super(creationDate);

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
  }) : super(DateTime.now().toUtc());
}
