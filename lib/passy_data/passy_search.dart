import 'package:passy/passy_data/password.dart';

class PassySearch {
  static List<PasswordMeta> searchPasswords(
      {required Iterable<PasswordMeta> passwords, required String terms}) {
    final List<PasswordMeta> _found = [];
    final List<String> _terms = terms.trim().toLowerCase().split(' ');
    for (PasswordMeta _password in passwords) {
      {
        bool testPassword(PasswordMeta value) => _password.key == value.key;

        if (_found.any(testPassword)) continue;
      }
      {
        int _positiveCount = 0;
        for (String _term in _terms) {
          if (_password.username.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
          if (_password.nickname.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
        }
        if (_positiveCount == _terms.length) {
          _found.add(_password);
        }
      }
    }
    return _found;
  }
}
