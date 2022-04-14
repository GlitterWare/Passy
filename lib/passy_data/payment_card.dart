import 'custom_field.dart';
import 'passy_entries.dart';
import 'passy_entries_file.dart';
import 'passy_entry.dart';

typedef PaymentCards = PassyEntries<PaymentCard>;

typedef PaymentCardsFile = PassyEntriesFile<PaymentCard>;

class PaymentCard extends PassyEntry<PaymentCard> {
  String nickname;
  String cardNumber;
  String cardholderName;
  String cvv;
  String exp;
  List<CustomField> customFields;
  String additionalInfo;
  List<String> tags;

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
        customFields = (json['customFields'] as List?)
                ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        additionalInfo = json['additionalInfo'] ?? '',
        tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
        super(json['key'] ?? DateTime.now().toUtc().toIso8601String());

  PaymentCard.fromCSV(List<dynamic> csv)
      : nickname = csv[1] ?? '',
        cardNumber = csv[2] ?? '',
        cardholderName = csv[3] ?? '',
        cvv = csv[4] ?? '',
        exp = csv[5] ?? '',
        customFields =
            (csv[6] as List?)?.map((e) => CustomField.fromCSV(e)).toList() ??
                [],
        additionalInfo = csv[7] ?? '',
        tags = (csv[8] as List?)?.map((e) => e as String).toList() ?? [],
        super(csv[0] ?? DateTime.now().toUtc().toIso8601String());

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
  List<dynamic> toCSV() => [
        key,
        nickname,
        cardNumber,
        cardholderName,
        cvv,
        exp,
        customFields.map((e) => e.toCSV()),
        additionalInfo,
        tags,
      ];
}
