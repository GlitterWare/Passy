import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';

import 'common/common.dart';
import 'passy_flutter.dart';

class PassySort {
  static void sortPasswords(List<PasswordMeta> passwords) {
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
      (a, b) => alphabeticalCompare(a.title, b.title),
    );
  }

  static void sortPaymentCards(List<PaymentCardMeta> paymentCards) {
    paymentCards.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.cardholderName, b.cardholderName);
      }
      return _nickComp;
    });
  }

  static void sortNotes(List<NoteMeta> notes) =>
      notes.sort((a, b) => alphabeticalCompare(a.title, b.title));

  static void sortIDCards(List<IDCardMeta> idCards) {
    idCards.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.name, b.name);
      }
      return _nickComp;
    });
  }

  static void sortIdentities(List<IdentityMeta> identities) {
    identities.sort((a, b) {
      int _nickComp = alphabeticalCompare(a.nickname, b.nickname);
      if (_nickComp == 0) {
        return alphabeticalCompare(a.firstAddressLine, b.firstAddressLine);
      }
      return _nickComp;
    });
  }

  static void sortEntries(List<SearchEntryData> entries) {
    entries.sort((a, b) {
      int _nameComp = alphabeticalCompare(a.name, b.name);
      if (_nameComp == 0) {
        return alphabeticalCompare(a.description, b.description);
      }
      return _nameComp;
    });
  }

  static void sortFiles(List<FileEntry> entries) {
    entries.sort((a, b) {
      if (a.type == FileEntryType.folder) {
        if (b.type != FileEntryType.folder) {
          return -1;
        }
      } else {
        if (b.type == FileEntryType.folder) {
          return 1;
        }
      }
      return alphabeticalCompare(a.path, b.path);
    });
  }
}
