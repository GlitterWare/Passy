import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/passy_flutter/common/always_disabled_focus_node.dart';

class CustomFieldEditor extends StatefulWidget {
  final CustomField customField;
  final void Function(String value)? onChanged;
  final void Function()? onRemovePressed;
  final ColorScheme? datePickerColorScheme;

  const CustomFieldEditor({
    Key? key,
    required this.customField,
    this.onChanged,
    this.onRemovePressed,
    this.datePickerColorScheme = PassyTheme.datePickerColorScheme,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFieldEditor();
}

class _CustomFieldEditor extends State<CustomFieldEditor> {
  String value = '';

  @override
  void initState() {
    super.initState();
    value = widget.customField.value;
  }

  @override
  Widget build(BuildContext context) {
    bool _isDate = widget.customField.fieldType == FieldType.date;
    DateTime? _date;
    if (_isDate) {
      if (widget.customField.value == '') {
        _date = DateTime.now();
      } else {
        List<String> _dateSplit = widget.customField.value.split('/');
        _date = DateTime(
          int.parse(_dateSplit[2]),
          int.parse(_dateSplit[1]),
          int.parse(_dateSplit[0]),
        );
      }
    }

    return ButtonedTextFormField(
      initialValue: widget.customField.value,
      focusNode: _isDate ? AlwaysDisabledFocusNode() : null,
      labelText: widget.customField.title,
      buttonIcon: const Icon(Icons.remove_rounded),
      onChanged: (value) {
        widget.customField.value = value;
        setState(() => value = value);
      },
      onTap: _isDate
          ? () => showDatePicker(
                context: context,
                initialDate:
                    widget.customField.value == '' ? DateTime.now() : _date!,
                firstDate: DateTime.utc(0, 04, 20),
                lastDate: DateTime.utc(275760, 09, 13),
                builder: (context, w) => Theme(
                  data: ThemeData(colorScheme: widget.datePickerColorScheme),
                  child: w!,
                ),
              ).then((value) {
                if (value == null) return;
                String _value = value.day.toString() +
                    '/' +
                    value.month.toString() +
                    '/' +
                    value.year.toString();
                widget.onChanged?.call(_value);
              })
          : null,
      onPressed: widget.onRemovePressed,
      inputFormatters: [
        if (widget.customField.fieldType == FieldType.number)
          FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
