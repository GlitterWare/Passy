import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'custom_field.dart';
import 'dated_entries.dart';
import 'dated_entry.dart';
import 'encrypted_json_file.dart';

typedef IDCards = DatedEntries<IDCard>;

class IDCardsFile extends EncryptedJsonFile<IDCards> {
  IDCardsFile._(File file, Encrypter encrypter, {required IDCards value})
      : super(file, encrypter, value: value);

  factory IDCardsFile(File file, Encrypter encrypter) {
    if (file.existsSync()) {
      return IDCardsFile._(file, encrypter,
          value: IDCards.fromJson(jsonDecode(
              decrypt(file.readAsStringSync(), encrypter: encrypter))));
    }
    file.createSync(recursive: true);
    IDCardsFile _file = IDCardsFile._(file, encrypter, value: IDCards());
    _file.saveSync();
    return _file;
  }
}

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
        'creationDate': creationDate,
      };

  factory IDCard.fromJson(Map<String, dynamic> json) => IDCard._(
        nickname: json['nickname'] ?? '',
        pictures: (json['pictures'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        type: json['type'] ?? '',
        idNumber: json['idNumber'] ?? '',
        name: json['name'] ?? '',
        issDate: json['issDate'] ?? '',
        expDate: json['expDate'] ?? '',
        country: json['country'] ?? '',
        customFields: (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo: json['additionalInfo'] ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        creationDate:
            json['creationDate'] ?? DateTime.now().toUtc().toIso8601String(),
      );

  IDCard._({
    required this.nickname,
    required this.pictures,
    required this.type,
    required this.idNumber,
    required this.name,
    required this.issDate,
    required this.expDate,
    required this.country,
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
    required String creationDate,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(creationDate);

  IDCard({
    required this.nickname,
    required this.pictures,
    required this.type,
    required this.idNumber,
    required this.name,
    required this.issDate,
    required this.expDate,
    required this.country,
    List<CustomField>? customFields,
    required this.additionalInfo,
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());
}
