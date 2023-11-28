import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/common/common.dart';

class EnumDropDownButtonFormField<T extends Enum> extends StatelessWidget {
  final T value;
  final List<T> values;
  final Widget Function(T object)? itemBuilder;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;
  final void Function(T? value)? onChanged;
  final TextStyle? style;
  final Widget? icon;
  final double iconSize;
  final bool isExpanded;
  final AlignmentGeometry alignment;

  const EnumDropDownButtonFormField({
    Key? key,
    required this.value,
    required this.values,
    this.itemBuilder,
    this.decoration,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.style,
    this.icon,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.alignment = AlignmentDirectional.centerStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<T>> _menuItems = [];
    for (T value in values) {
      String _name;
      switch (textCapitalization) {
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
        child: itemBuilder?.call(value) ?? Text(_name),
        value: value,
      ));
    }
    return DropdownButtonFormField(
      items: _menuItems,
      value: value,
      decoration: decoration,
      onChanged: onChanged,
      style: style,
      icon: icon,
      iconSize: iconSize,
      isExpanded: isExpanded,
      alignment: alignment,
    );
  }
}
