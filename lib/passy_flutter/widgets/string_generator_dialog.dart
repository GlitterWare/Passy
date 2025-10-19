import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class StringGeneratorDialog extends StatefulWidget {
  const StringGeneratorDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StringGeneratorDialog();
}

class _StringGeneratorDialog extends State<StringGeneratorDialog> {
  String _value = '';
  int _length = 18;
  bool _numbersEnabled = true;
  bool _symbolsEnabled = true;
  bool _shouldGenerate = false;
  Future<void>? _generateLoopFuture;

  void _generatePassword() {
    setState(() => _value = PassyGen.generateComplexPassword(
        length: _length,
        includeNumbers: _numbersEnabled,
        includeSymbols: _symbolsEnabled));
  }

  Future<void> _generateLoop() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_shouldGenerate) {
        if (_value.length != _length) {
          _generatePassword();
        }
        continue;
      }
      _shouldGenerate = false;
      _generatePassword();
      if (!mounted) return;
    }
  }

  void _setNumbersEnabled(bool value) {
    setState(() {
      _numbersEnabled = value;
      _shouldGenerate = true;
    });
  }

  void _setSymbolsEnabled(bool value) {
    setState(() {
      _symbolsEnabled = value;
      _shouldGenerate = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    _generateLoopFuture ??= _generateLoop();
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
              value: _symbolsEnabled,
              onChanged: (value) => _setSymbolsEnabled(_symbolsEnabled = value),
            ),
            onPressed: () => _setSymbolsEnabled(!_symbolsEnabled),
          )),
          Padding(
            padding: EdgeInsets.fromLTRB(
              PassyTheme.of(context).passyPadding.left,
              PassyTheme.of(context).passyPadding.top,
              PassyTheme.of(context).passyPadding.right,
              0,
            ),
            child: Text(
              _length.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              PassyTheme.of(context).passyPadding.left,
              0,
              PassyTheme.of(context).passyPadding.right,
              0,
            ),
            child: Slider(
              value: _length.toDouble(),
              onChanged: (value) => setState(() {
                _length = value.toInt();
                _shouldGenerate = true;
              }),
              min: 4.0,
              max: 200.0,
              inactiveColor: PassyTheme.of(context).contentSecondaryColor,
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
                  onPressed: () => setState(() => _shouldGenerate = true),
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
