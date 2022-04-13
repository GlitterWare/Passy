import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef IDCards = PassyEntries<IDCard>;

typedef IDCardsFile = PassyEntriesFile<IDCard>;

class IDCard extends PassyEntry<IDCard> {
  static const csvSchema = {
    'key': 1,
    'nickname': 2,
    'pictures': 3,
    'type': 4,
    'idNumber': 5,
    'name': 6,
    'issDate': 7,
    'expDate': 8,
    'country': 9,
    'additionalInfo': 10,
  };

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

  IDCard._({
    required String key,
    this.nickname = '',
    List<String>? pictures,
    this.type = '',
    this.idNumber = '',
    this.name = '',
    this.issDate = '',
    this.expDate = '',
    this.country = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : pictures = pictures ?? [],
        customFields = customFields ?? [],
        tags = tags ?? [],
        super(key);

  IDCard({
    this.nickname = '',
    List<String>? pictures,
    this.type = '',
    this.idNumber = '',
    this.name = '',
    this.issDate = '',
    this.expDate = '',
    this.country = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : pictures = pictures ?? [],
        customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  IDCard.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
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
        customFields = (json['customFields'] as List<dynamic>?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  factory IDCard.fromCSV(
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> schemas = const {
      'idCard': csvSchema,
      'customField': CustomField.csvSchema,
    },
  }) {
    Map<String, int> _objectSchema = schemas['idCard'] ?? csvSchema;
    Map<String, int> _customFieldSchema =
        schemas['customField'] ?? CustomField.csvSchema;

    IDCard? _object;
    List<String> _pictures = [];
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'idCard':
          _object = IDCard._(
            key: entry[_objectSchema['key']!],
            nickname: entry[_objectSchema['nickname']!],
            type: entry[_objectSchema['type']!],
            idNumber: entry[_objectSchema['idNumber']!],
            name: entry[_objectSchema['name']!],
            issDate: entry[_objectSchema['issDate']!],
            expDate: entry[_objectSchema['expDate']!],
            country: entry[_objectSchema['country']!],
            additionalInfo: entry[_objectSchema['additionalInfo']!],
          );
          break;
        case 'pictures':
          List<String> _entry = (entry as List<String>).toList()..removeAt(0);
          _pictures.addAll(_entry);
          break;
        case 'customFields':
          _customFields
              .add(CustomField.fromCSV(entry, csvSchema: _customFieldSchema));
          break;
        case 'tags':
          List<String> _entry = (entry as List<String>).toList()..removeAt(0);
          _tags.addAll(_entry);
          break;
      }
    }

    _object!
      ..pictures = _pictures
      ..customFields = _customFields
      ..tags = _tags;
    return _object;
  }

  @override
  int compareTo(IDCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
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
      };

  @override
  List<List<dynamic>> toCSV() => jsonToCSV('idCard', toJson());
}
