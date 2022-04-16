import 'custom_field.dart';
import 'encrypted_csv_file.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';

typedef PaymentCards = PassyEntries<PaymentCard>;

typedef PaymentCardsFile = EncryptedCSVFile<PaymentCards>;

class PaymentCard extends PassyEntry<PaymentCard> {
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;

  PaymentCard({
    List<CustomField>? customFields,
    this.additionalInfo = '',
    List<String>? tags,
    this.nickname = '',
    this.cardNumber = '',
    this.cardholderName = '',
    this.cvv = '',
    this.exp = '',
  })  : customFields = customFields ?? [],
        tags = tags ?? [],
        super(DateTime.now().toUtc().toIso8601String());

  PaymentCard.fromJson(Map<String, dynamic> json)
      : customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = json['nickname'] ?? '',
        cardNumber = json['cardNumber'] ?? '',
        cardholderName = json['cardholderName'] ?? '',
        cvv = json['cvv'] ?? '',
        exp = json['exp'] ?? '',
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  PaymentCard.fromCSV(List csv)
      : customFields =
            (csv[1] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[2] ?? '',
        tags = (csv[3] as List?)?.map((e) => e as String).toList() ?? [],
        nickname = csv[4] ?? '',
        cardNumber = csv[5] ?? '',
        cardholderName = csv[6] ?? '',
        cvv = csv[7] ?? '',
        exp = csv[8] ?? '',
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

  @override
  int compareTo(PaymentCard other) => nickname.compareTo(other.nickname);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'customFields': customFields.map((e) => e.toJson()).toList(),
        'additionalInfo': additionalInfo,
        'tags': tags,
        'nickname': nickname,
        'cardNumber': cardNumber,
        'cardholderName': cardholderName,
        'cvv': cvv,
        'exp': exp,
      };

  @override
  List<List> toCSV() => [
        [
          customFields.map((e) => e.toCSV()),
          additionalInfo,
          tags,
          key,
          nickname,
          cardNumber,
          cardholderName,
          cvv,
          exp,
        ]
      ];
}
