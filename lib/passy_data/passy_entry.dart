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

  static PassyEntry fromJson(EntryType entryType, Map<String, dynamic> json) {
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

  static PassyEntry fromCSV(
    EntryType entryType,
    List<List<dynamic>> csv, {
    Map<String, Map<String, int>> templates = const {},
  }) {
    switch (entryType) {
      case EntryType.password:
        return Password.fromCSV(
          csv,
          templates: templates,
        );
      case EntryType.passwordIcon:
        return PassyBytes.fromCSV(
          csv,
          templates: templates,
        );
      case EntryType.paymentCard:
        return PaymentCard.fromCSV(
          csv,
          templates: templates,
        );
      case EntryType.note:
        return Note.fromCSV(
          csv,
          templates: templates,
        );
      case EntryType.idCard:
        return IDCard.fromCSV(
          csv,
          templates: templates,
        );
      case EntryType.identity:
        return Identity.fromCSV(
          csv,
          templates: templates,
        );
      default:
        throw Exception(
            'CSV conversion not supported for EntryType \'${entryType.name}\'');
    }
  }
}
