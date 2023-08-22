import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class StringGeneratorDialog extends StatefulWidget {
  const StringGeneratorDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StringGeneratorDialog();
}

class _StringGeneratorDialog extends State<StringGeneratorDialog> {
  static const String _letters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '1234567890';
  static const String _symbols = '.,;#&()^*_-';
  static const double _minSpecial = 8 / 25;
  static const double _halfMinSpecial = 4 / 25;

  String _value = '';
  int _length = 18;
  bool _numbersEnabled = true;
  bool _symbolsEnabled = true;
  String _characterSet = _letters + _numbers + _symbols;

  _StringGeneratorDialog() {
    _generatePassword();
  }

  void _generatePassword() {
    int minSpecial;
    if (_numbersEnabled && _symbolsEnabled) {
      minSpecial = (_halfMinSpecial * _length).round();
      while (true) {
        _value = PassyGen.generateString(_characterSet, _length);
        int numCount = 0;
        int symCount = 0;
        for (String c in _value.characters) {
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
            break;
          }
        }
      }
    } else if (_numbersEnabled || _symbolsEnabled) {
      minSpecial = (_minSpecial * _length).round();
      String special;
      if (_numbersEnabled) {
        special = _numbers;
      } else {
        special = _symbols;
      }
      while (true) {
        _value = PassyGen.generateString(_characterSet, _length);
        int specialCount = 0;
        for (String c in _value.characters) {
          if (special.contains(c)) {
            specialCount++;
            continue;
          }
        }
        if (specialCount >= minSpecial) break;
      }
    } else {
      _value = PassyGen.generateString(_characterSet, _length);
      return;
    }
  }

  void _buildCharacterSet() {
    _characterSet = _letters;
    if (_numbersEnabled) _characterSet += _numbers;
    if (_symbolsEnabled) _characterSet += _symbols;
  }

  void _setNumbersEnabled(bool value) {
    setState(() {
      _numbersEnabled = value;
      _buildCharacterSet();
      _generatePassword();
    });
  }

  void _setSymbolsEnabled(bool value) {
    setState(() {
      _symbolsEnabled = value;
      _buildCharacterSet();
      _generatePassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: PassyTheme.dialogShape,
      child: ListView(
        shrinkWrap: true,
        children: [
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.numbers),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.numbers),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: _numbersEnabled,
              onChanged: (value) => _setNumbersEnabled(value),
            ),
            onPressed: () => _setNumbersEnabled(!_numbersEnabled),
          )),
          PassyPadding(ThreeWidgetButton(
            center: Text(localizations.symbols),
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.star),
            ),
            right: Switch(
              activeColor: Colors.greenAccent,
              value: _symbolsEnabled,
              onChanged: (value) => _setSymbolsEnabled(_symbolsEnabled = value),
            ),
            onPressed: () => _setSymbolsEnabled(!_symbolsEnabled),
          )),
          Padding(
            padding: EdgeInsets.fromLTRB(
              PassyTheme.passyPadding.left,
              PassyTheme.passyPadding.top,
              PassyTheme.passyPadding.right,
              0,
            ),
            child: Text(
              _length.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              PassyTheme.passyPadding.left,
              0,
              PassyTheme.passyPadding.right,
              0,
            ),
            child: Slider(
              value: _length.toDouble(),
              onChanged: (value) => setState(() {
                _length = value.toInt();
                _generatePassword();
              }),
              min: 4.0,
              max: 200.0,
              activeColor: Colors.cyan,
              thumbColor: Colors.cyanAccent,
              inactiveColor: PassyTheme.darkContentSecondaryColor,
            ),
          ),
          PassyPadding(SelectableText(
            _value,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          )),
          Row(
            children: [
              const Spacer(),
              PassyPadding(
                FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.cancel,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded),
                ),
              ),
              PassyPadding(
                FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.generate,
                  onPressed: () => setState(() => _generatePassword()),
                  child: const Icon(Icons.refresh_rounded),
                ),
              ),
              PassyPadding(
                FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.done,
                  onPressed: () => Navigator.pop(context, _value),
                  child: const Icon(Icons.check_rounded),
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
