import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class EnumDropDownButtonFormField<T extends Enum> extends StatelessWidget {
  final T _value;
  final List<T> _values;
  final InputDecoration? _decoration;
  final TextCapitalization _textCapitalization;
  final void Function(T? value)? _onChanged;

  const EnumDropDownButtonFormField(
      {Key? key,
      required T value,
      required List<T> values,
      InputDecoration? decoration,
      TextCapitalization textCapitalization = TextCapitalization.none,
      void Function(T? value)? onChanged})
      : _value = value,
        _values = values,
        _decoration = decoration,
        _textCapitalization = textCapitalization,
        _onChanged = onChanged,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<T>> _menuItems = [];
    for (T value in _values) {
      String _name;
      switch (_textCapitalization) {
        case (TextCapitalization.characters):
          _name = value.name.toUpperCase();
          break;
        case (TextCapitalization.none):
          _name = value.name;
          break;
        case (TextCapitalization.sentences):
          _name = capitalize(value.name);
          break;
        case (TextCapitalization.words):
          _name = capitalize(value.name);
          break;
        default:
          _name = value.name;
          break;
      }
      _menuItems.add(DropdownMenuItem(
        child: Text(_name),
        value: value,
      ));
    }
    return DropdownButtonFormField(
      items: _menuItems,
      value: _value,
      decoration: _decoration,
      onChanged: _onChanged,
    );
  }
}
