import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:passy/common/always_disabled_focus_node.dart';
import 'package:passy/passy_flutter/theme.dart';

class MonthPickerFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final TextStyle buttonStyle;
  final TextStyle currentDateStyle;
  final TextStyle selectedDateStyle;
  final Widget? title;
  final DateTime Function()? getSelectedDate;
  final Function(DateTime)? onChanged;

  MonthPickerFormField({
    Key? key,
    this.controller,
    this.initialValue,
    TextStyle? buttonStyle,
    TextStyle? currentDateStyle,
    TextStyle? selectedDateStyle,
    this.title,
    this.getSelectedDate,
    this.onChanged,
  })  : buttonStyle =
            buttonStyle ?? TextStyle(color: lightContentSecondaryColor),
        currentDateStyle =
            currentDateStyle ?? TextStyle(color: lightContentSecondaryColor),
        selectedDateStyle =
            selectedDateStyle ?? TextStyle(color: lightContentSecondaryColor),
        super(key: key);

  @override
  Widget build(context) {
    return TextFormField(
        controller: controller,
        initialValue: initialValue,
        decoration: const InputDecoration(labelText: 'Expiration date'),
        focusNode: AlwaysDisabledFocusNode(),
        onTap: () => showDialog(
              context: context,
              builder: (ctx) {
                DateTime _selectedDate = getSelectedDate == null
                    ? DateTime.now().toUtc()
                    : getSelectedDate!();
                return AlertDialog(
                  title: title,
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancel',
                          style: buttonStyle,
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, _selectedDate),
                        child: Text(
                          'Confirm',
                          style: buttonStyle,
                        )),
                  ],
                  content: StatefulBuilder(
                    builder: (ctx, setState) {
                      return MonthPicker.single(
                        selectedDate: _selectedDate,
                        firstDate: DateTime.utc(-4294967296),
                        lastDate: DateTime.utc(4294967296),
                        onChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                        datePickerStyles: DatePickerStyles(
                            currentDateStyle: currentDateStyle,
                            selectedDateStyle: selectedDateStyle),
                      );
                    },
                  ),
                );
              },
            ).then((value) {
              if (onChanged != null) onChanged!(value);
            }));
  }
}
