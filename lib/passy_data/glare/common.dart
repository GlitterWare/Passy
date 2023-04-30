import 'dart:math';

const String rsaSocketVersion = '1.0.0';
const String glareProtocolVersion = '1.0.0';

const int _passwordLength = 32;
const String _passwordLetters =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,;#&()^*_-';

String generatePassword() {
  String _result = '';
  Random _random = Random.secure();
  for (int i = 0; i != _passwordLength; i++) {
    _result += _passwordLetters[_random.nextInt(_passwordLetters.length)];
  }
  return _result;
}
