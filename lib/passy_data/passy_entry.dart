import 'csv_convertable.dart';
import 'entry_type.dart';
import 'id_card.dart';
import 'identity.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

abstract class PassyEntry<T> with JsonConvertable, CSVConvertable {
  final String key;

  PassyEntry(this.key);

  int compareTo(T other);

  static PassyEntry Function(Map<String, dynamic> json) fromJson(
      EntryType entryType) {
    switch (entryType) {
      case EntryType.password:
        return Password.fromJson;
      case EntryType.paymentCard:
        return PaymentCard.fromJson;
      case EntryType.note:
        return Note.fromJson;
      case EntryType.idCard:
        return IDCard.fromJson;
      case EntryType.identity:
        return Identity.fromJson;
      default:
        throw Exception(
            'Json conversion not supported for EntryType \'${entryType.name}\'');
    }
  }

  static PassyEntry Function(List csv) fromCSV<T>(entryType) {
    switch (entryType) {
      case EntryType.password:
        return Password.fromCSV;
      case EntryType.paymentCard:
        return PaymentCard.fromCSV;
      case EntryType.note:
        return Note.fromCSV;
      case EntryType.idCard:
        return IDCard.fromCSV;
      case EntryType.identity:
        return Identity.fromCSV;
      default:
        throw Exception(
            'CSV conversion not supported for EntryType \'${entryType.name}\'');
    }
  }
}
