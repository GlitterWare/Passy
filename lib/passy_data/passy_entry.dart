import 'csv_convertable.dart';
import 'entry_type.dart';
import 'id_card.dart';
import 'identity.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'passy_bytes.dart';
import 'payment_card.dart';

abstract class PassyEntry<T extends PassyEntry<T>>
    implements JsonConvertable, CSVConvertable {
  final String key;

  PassyEntry(this.key);

  int compareTo(T other);

  static PassyEntry<dynamic> fromJson(
      EntryType entryType, Map<String, dynamic> json) {
    switch (entryType) {
      case EntryType.password:
        return Password.fromJson(json);
      case EntryType.paymentCard:
        return PaymentCard.fromJson(json);
      case EntryType.note:
        return Note.fromJson(json);
      case EntryType.idCard:
        return IDCard.fromJson(json);
      case EntryType.identity:
        return Identity.fromJson(json);
      default:
        throw Exception(
            'Json conversion not supported for EntryType \'${entryType.name}\'');
    }
  }

  static PassyEntry<dynamic> fromCSV(
    EntryType entryType,
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> schemas = const {},
  }) {
    switch (entryType) {
      case EntryType.password:
        return Password.fromCSV(
          csv,
          schemas: schemas,
        );
      case EntryType.passwordIcon:
        return PassyBytes.fromCSV(
          csv,
          schemas: schemas,
        );
      case EntryType.paymentCard:
        return PaymentCard.fromCSV(
          csv,
          schemas: schemas,
        );
      case EntryType.note:
        return Note.fromCSV(
          csv,
          schemas: schemas,
        );
      case EntryType.idCard:
        return IDCard.fromCSV(
          csv,
          schemas: schemas,
        );
      case EntryType.identity:
        return Identity.fromCSV(
          csv,
          schemas: schemas,
        );
      default:
        throw Exception(
            'CSV conversion not supported for EntryType \'${entryType.name}\'');
    }
  }
}
