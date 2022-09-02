import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';

import 'common/common.dart';

class PassySort {
  static void sortPasswords(List<Password> passwords) {
    passwords.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.username, b.username);
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
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.cardholderName, b.cardholderName);
      }
      return _nickComp;
    });
  }

  static void sortNotes(List<Note> notes) =>
      notes.sort((a, b) => a.title.compareTo(b.title));

  static void sortIDCards(List<IDCard> idCards) {
    idCards.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.name, b.name);
      }
      return _nickComp;
    });
  }

  static void sortIdentities(List<Identity> identities) {
    identities.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.firstAddressLine, b.firstAddressLine);
      }
      return _nickComp;
    });
  }
}
