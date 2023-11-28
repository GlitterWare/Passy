import 'entry_type.dart';
import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'passy_entries_encrypted_csv_file.dart';
import 'payment_card.dart';

class PassyEntriesFileCollection {
  PasswordsFile? passwords;
  NotesFile? notes;
  PaymentCardsFile? paymentCards;
  IDCardsFile? idCards;
  IdentitiesFile? identities;

  PassyEntriesFileCollection({
    this.passwords,
    this.notes,
    this.paymentCards,
    this.idCards,
    this.identities,
  });

  toFull() => FullPassyEntriesFileCollection(
        passwords: passwords!,
        notes: notes!,
        paymentCards: paymentCards!,
        idCards: idCards!,
        identities: identities!,
      );

  PassyEntriesEncryptedCSVFile? getEntries(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords;
      case EntryType.paymentCard:
        return paymentCards;
      case EntryType.note:
        return notes;
      case EntryType.idCard:
        return idCards;
      case EntryType.identity:
        return identities;
    }
  }
}

class FullPassyEntriesFileCollection extends PassyEntriesFileCollection {
  FullPassyEntriesFileCollection({
    required PasswordsFile passwords,
    required NotesFile notes,
    required PaymentCardsFile paymentCards,
    required IDCardsFile idCards,
    required IdentitiesFile identities,
  }) : super(
          passwords: passwords,
          notes: notes,
          paymentCards: paymentCards,
          idCards: idCards,
          identities: identities,
        );

  @override
  PassyEntriesEncryptedCSVFile getEntries(EntryType type) =>
      super.getEntries(type)!;
}
