import 'package:flutter/material.dart';
import 'dart:math';

class PassyGen {
  static const String _letters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '1234567890';
  static const String _symbols = '.,;#&()^*_-';
  static const double _minSpecial = 8 / 25;
  static const double _halfMinSpecial = 4 / 25;

  static String generateString(String characterSet, int length) {
    String _result = '';
    Random _random = Random.secure();
    for (int i = 0; i != length; i++) {
      _result += characterSet[_random.nextInt(characterSet.length)];
    }
    return _result;
  }

  static String generateComplexPassword(
      {int length = 18,
      bool includeNumbers = true,
      bool includeSymbols = true}) {
    String _characterSet = _letters;
    if (!includeNumbers && !includeSymbols) {
      return generateString(_characterSet, length);
    }
    if (includeNumbers) _characterSet += _numbers;
    if (includeSymbols) _characterSet += _symbols;
    String newVal = '';
    int minSpecial;
    if (includeNumbers && includeSymbols) {
      minSpecial = (_halfMinSpecial * length).round();
      while (true) {
        newVal = PassyGen.generateString(_characterSet, length);
        int numCount = 0;
        int symCount = 0;
        for (String c in newVal.characters) {
          if (_numbers.contains(c)) {
            numCount++;
            continue;
          }
          if (_symbols.contains(c)) {
            symCount++;
            continue;
          }
        }
        if (numCount >= minSpecial) {
          if (symCount >= minSpecial) {
            return newVal;
          }
        }
      }
    } else {
      minSpecial = (_minSpecial * length).round();
      String special;
      if (includeNumbers) {
        special = _numbers;
      } else {
        special = _symbols;
      }
      while (true) {
        newVal = PassyGen.generateString(_characterSet, length);
        int specialCount = 0;
        for (String c in newVal.characters) {
          if (special.contains(c)) {
            specialCount++;
            continue;
          }
        }
        if (specialCount >= minSpecial) return newVal;
      }
    }
  }
}
