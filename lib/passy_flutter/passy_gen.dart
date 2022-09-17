import 'dart:math';

class PassyGen {
  static String generateString(String characterSet, int length) {
    String _result = '';
    Random _random = Random.secure();
    for (int i = 0; i != length; i++) {
      _result += characterSet[_random.nextInt(characterSet.length)];
    }
    return _result;
  }
}
