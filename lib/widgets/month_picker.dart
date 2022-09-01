import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:passy/common/always_disabled_focus_node.dart';
import 'package:passy/common/theme.dart';

class MonthPickerFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final Widget? title;
  final DateTime Function()? getSelectedDate;
  final Function(DateTime)? onChanged;

  const MonthPickerFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.title,
    this.getSelectedDate,
    this.onChanged,
  }) : super(key: key);

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
                          style: TextStyle(color: lightContentSecondaryColor),
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, _selectedDate),
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: lightContentSecondaryColor),
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
                            currentDateStyle:
                                TextStyle(color: lightContentSecondaryColor),
                            selectedDateStyle:
                                TextStyle(color: lightContentSecondaryColor)),
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
