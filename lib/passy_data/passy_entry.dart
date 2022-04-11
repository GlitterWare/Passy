import 'entry_type.dart';
import 'error_entry.dart';
import 'id_card.dart';
import 'identity.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

abstract class PassyEntry<T> implements JsonConvertable {
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
        return ErrorEntry();
    }
  }
}
