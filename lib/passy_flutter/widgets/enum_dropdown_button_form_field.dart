import 'package:flutter/material.dart';
import '../common/common.dart';

class EnumDropDownButtonFormField<T extends Enum> extends StatelessWidget {
  final T value;
  final List<T> values;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;
  final void Function(T? value)? onChanged;

  const EnumDropDownButtonFormField({
    Key? key,
    required this.value,
    required this.values,
    this.decoration,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<T>> menuItems = [];
    for (T value in values) {
      String name;
      switch (textCapitalization) {
        case (TextCapitalization.characters):
          name = value.name.toUpperCase();
          break;
        case (TextCapitalization.none):
          name = value.name;
          break;
        case (TextCapitalization.sentences):
          name = capitalize(value.name);
          break;
        case (TextCapitalization.words):
          name = capitalize(value.name);
          break;
        default:
          name = value.name;
          break;
      }
      menuItems.add(DropdownMenuItem(
        value: value,
        child: Text(name),
      ));
    }
    return DropdownButtonFormField(
      items: menuItems,
      value: value,
      decoration: decoration,
      onChanged: onChanged,
    );
  }
}
