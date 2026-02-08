import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/kdbx_convertable.dart';

import 'common.dart';
import 'csv_convertable.dart';
import 'entry_type.dart';
import 'id_card.dart';
import 'identity.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

abstract class PassyEntry<T>
    with JsonConvertable, CSVConvertable, KdbxConvertable {
  final String key;

  PassyEntry(this.key);

  EntryMeta get metadata;
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

  static PassyEntry fromCSVString<T>(String csvEntry) {
    EntryType entryType = entryTypeFromType(T)!;
    List<String> decoded1 = csvEntry.split(',');
    String key = decoded1[0];
    try {
      List<dynamic> decoded2 = csvDecode(csvEntry, recursive: true);
      return PassyEntry.fromCSV(entryType)(decoded2);
    } catch (_) {
      switch (entryType) {
        case EntryType.password:
          return Password(
              key: key,
              nickname: 'Recovered entry',
              additionalInfo: 'Data recovered from corrupted entry: $csvEntry');
        case EntryType.paymentCard:
          return PaymentCard(
              key: key,
              nickname: 'Recovered entry',
              additionalInfo: 'Data recovered from corrupted entry: $csvEntry');
        case EntryType.note:
          return Note(
              key: key,
              title: 'Recovered entry',
              note: 'Data recovered from corrupted entry: $csvEntry');
        case EntryType.idCard:
          return IDCard(
              key: key,
              nickname: 'Recovered entry',
              additionalInfo: 'Data recovered from corrupted entry: $csvEntry');
        case EntryType.identity:
          return Identity(
              key: key,
              nickname: 'Recovered entry',
              additionalInfo: 'Data recovered from corrupted entry: $csvEntry');
      }
    }
  }
}
