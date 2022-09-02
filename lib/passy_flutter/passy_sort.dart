import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';

class PassySort {
  static void sortPasswords(List<Password> passwords) {
    passwords.sort((a, b) {
      int _nickComp = a.nickname.compareTo(b.nickname);
      if (_nickComp == 0) {
        return a.username.compareTo(b.username);
      }
      return _nickComp;
    });
  }

  static void sortCustomFields(List<CustomField> customFields) {
    customFields.sort(
      (a, b) => a.title.compareTo(b.title),
    );
  }

  static void sortPaymentCards(List<PaymentCard> paymentCards) {
    paymentCards.sort((a, b) {
      int _nickComp = a.nickname.compareTo(b.nickname);
      if (_nickComp == 0) {
        return a.cardholderName.compareTo(b.cardholderName);
      }
      return _nickComp;
    });
  }

  static void sortNotes(List<Note> notes) =>
      notes.sort((a, b) => a.title.compareTo(b.title));

  static void sortIDCards(List<IDCard> idCards) {
    idCards.sort((a, b) {
      int _nickComp = a.nickname.compareTo(b.nickname);
      if (_nickComp == 0) {
        return a.name.compareTo(b.name);
      }
      return _nickComp;
    });
  }

  static void sortIdentities(List<Identity> identities) {
    identities.sort((a, b) {
      int _nickComp = a.nickname.compareTo(b.nickname);
      if (_nickComp == 0) {
        return a.firstAddressLine.compareTo(b.firstAddressLine);
      }
      return _nickComp;
    });
  }
}
