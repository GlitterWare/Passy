import 'dart:math';

class PassyGen {
  static String generateString(String characterSet, int length) {
    String result = '';
    Random random = Random.secure();
    for (int i = 0; i != length; i++) {
      result += characterSet[random.nextInt(characterSet.length)];
    }
    return result;
  }
}
