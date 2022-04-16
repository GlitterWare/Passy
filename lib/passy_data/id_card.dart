import 'package:passy/passy_data/encrypted_csv_file.dart';

import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef IDCards = PassyEntries<IDCard>;

typedef IDCardsFile = EncryptedCSVFile<IDCards>;

class IDCard extends PassyEntry<IDCard> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  List<String> pictures;
  String type;
  String idNumber;
  String name;
  String issDate;
  String expDate;
  String country;

  IDCard({
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    List<String>? pictures,
    this.type = '',
    this.idNumber = '',
    this.name = '',
    this.issDate = '',
    this.expDate = '',
    this.country = '',
  })  : pictures = pictures ?? [],
        customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  IDCard.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        pictures = (json['pictures'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        type = json['type'] ?? '',
        idNumber = json['idNumber'] ?? '',
        name = json['name'] ?? '',
        issDate = json['issDate'] ?? '',
        expDate = json['expDate'] ?? '',
        country = json['country'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  IDCard.fromCSV(List csv)
      : customFields =
            (csv[1] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[2] ?? '',
        tags =
            (csv[3] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        pictures = (csv[5] as List?)?.map((e) => e as String).toList() ?? [],
        type = csv[6] ?? '',
        idNumber = csv[7] ?? '',
        name = csv[8] ?? '',
        issDate = csv[9] ?? '',
        expDate = csv[10] ?? '',
        country = csv[11] ?? '',
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(IDCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'pictures': pictures,
        'type': type,
        'idNumber': idNumber,
        'name': name,
        'issDate': issDate,
        'expDate': expDate,
        'country': country,
      };

  @override
  List<List> toCSV() => [
        [
          key,
          customFields.map((e) => e.toCSV()),
          additionalInfo,
          tags,
          nickname,
          pictures,
          type,
          idNumber,
          name,
          issDate,
          expDate,
          country,
        ]
      ];
}
