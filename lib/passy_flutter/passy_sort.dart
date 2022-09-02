import 'package:passy/passy_data/password.dart';

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
}
