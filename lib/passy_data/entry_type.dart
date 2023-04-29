import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

enum EntryType {
  password,
  paymentCard,
  note,
  idCard,
  identity,
}

EntryType? entryTypeFromName(String name) {
  switch (name) {
    case 'password':
      return EntryType.password;
    case 'paymentCard':
      return EntryType.paymentCard;
    case 'note':
      return EntryType.note;
    case 'idCard':
      return EntryType.idCard;
    case 'identity':
      return EntryType.identity;
  }
  return null;
}

EntryType? entryTypeFromType(Type type) {
  switch (type) {
    case Password:
      return EntryType.password;
    case PaymentCard:
      return EntryType.paymentCard;
    case Note:
      return EntryType.note;
    case IDCard:
      return EntryType.idCard;
    case Identity:
      return EntryType.identity;
  }
  return null;
}

Type entryTypeToType(EntryType type) {
  switch (type) {
    case EntryType.password:
      return Password;
    case EntryType.paymentCard:
      return PaymentCard;
    case EntryType.note:
      return Note;
    case EntryType.idCard:
      return IDCard;
    case EntryType.identity:
      return Identity;
  }
}

String entryTypeToNamePlural(EntryType type) {
  switch (type) {
    case EntryType.password:
      return 'passwords';
    case EntryType.paymentCard:
      return 'paymentCards';
    case EntryType.note:
      return 'notes';
    case EntryType.idCard:
      return 'idCards';
    case EntryType.identity:
      return 'identities';
  }
}
