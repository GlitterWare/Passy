import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/always_disabled_focus_node.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/screens/common.dart';

class CustomFieldEditor extends StatelessWidget {
  final CustomField _customField;
  final void Function(String value)? _onChanged;
  final void Function()? _onRemovePressed;

  const CustomFieldEditor({
    Key? key,
    required CustomField customField,
    void Function(String value)? onChanged,
    void Function()? onRemovePressed,
  })  : _customField = customField,
        _onChanged = onChanged,
        _onRemovePressed = onRemovePressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller =
        TextEditingController(text: _customField.value);
    bool _isDate = _customField.fieldType == FieldType.date;
    DateTime? _date;
    if (_isDate) {
      if (_customField.value == '') {
        _date = DateTime.now();
      } else {
        List<String> _dateSplit = _customField.value.split('/');
        _date = DateTime(
          int.parse(_dateSplit[2]),
          int.parse(_dateSplit[1]),
          int.parse(_dateSplit[0]),
        );
      }
    }

    return getTextFormFieldButtoned(
      controller: _controller,
      focusNode: _isDate ? AlwaysDisabledFocusNode() : null,
      labelText: _customField.title,
      buttonIcon: const Icon(Icons.remove_rounded),
      onChanged: (value) => _customField.value = value,
      onTap: _isDate
          ? () => showDatePicker(
                context: context,
                initialDate: _customField.value == '' ? DateTime.now() : _date!,
                firstDate: DateTime.utc(0, 04, 20),
                lastDate: DateTime.utc(275760, 09, 13),
                builder: (context, widget) => Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.dark(
                      primary: lightContentSecondaryColor,
                      onPrimary: lightContentColor,
                    ),
                  ),
                  child: widget!,
                ),
              ).then((value) {
                if (value == null) return;
                String _value = value.day.toString() +
                    '/' +
                    value.month.toString() +
                    '/' +
                    value.year.toString();
                _controller.text = _value;
                _onChanged?.call(_value);
              })
          : null,
      onPressed: _onRemovePressed,
      inputFormatters: [
        if (_customField.fieldType == FieldType.number)
          FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
