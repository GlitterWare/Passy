import 'common.dart';
import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef PaymentCards = PassyEntries<PaymentCard>;

typedef PaymentCardsFile = PassyEntriesFile<PaymentCard>;

class PaymentCard extends PassyEntry<PaymentCard> {
  static const csvSchema = {
    'key': 1,
    'nickname': 2,
    'cardNumber': 3,
    'cardholderName': 4,
    'cvv': 5,
    'exp': 6,
    'additionalInfo': 7,
  };

  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

  PaymentCard._({
    required String key,
    this.nickname = '',
    this.cardNumber = '',
    this.cardholderName = '',
    this.cvv = '',
    this.exp = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(key);

  PaymentCard({
    this.nickname = '',
    this.cardNumber = '',
    this.cardholderName = '',
    this.cvv = '',
    this.exp = '',
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  PaymentCard.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? '',
        cardNumber = json['cardNumber'] ?? '',
        cardholderName = json['cardholderName'] ?? '',
        cvv = json['cvv'] ?? '',
        exp = json['exp'] ?? '',
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

  factory PaymentCard.fromCSV(
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> schemas = const {
      'paymentCard': csvSchema,
      'customField': CustomField.csvSchema,
    },
  }) {
    Map<String, int> _objectSchema = schemas['paymentCard'] ?? csvSchema;
    Map<String, int> _customFieldSchema =
        schemas['customField'] ?? CustomField.csvSchema;

    PaymentCard? _object;
    List<CustomField> _customFields = [];
    List<String> _tags = [];

    for (List<dynamic> entry in csv) {
      switch (entry[0]) {
        case 'paymentCard':
          _object = PaymentCard._(
            key: entry[_objectSchema['key']!],
            cardNumber: entry[_objectSchema['cardNumber']!],
            cardholderName: entry[_objectSchema['cardholderName']!],
            cvv: entry[_objectSchema['cvv']!],
            exp: entry[_objectSchema['exp']!],
            additionalInfo: entry[_objectSchema['additionalInfo']!],
          );
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
      ..customFields = _customFields
      ..tags = _tags;
    return _object;
  }

  @override
  int compareTo(PaymentCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
      };

  @override
  List<List<dynamic>> toCSV() => jsonToCSV(toJson());
}
