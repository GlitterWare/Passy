import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/common/always_disabled_focus_node.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

class MonthPickerFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final TextStyle? buttonStyle;
  final TextStyle? currentDateStyle;
  final TextStyle? selectedDateStyle;
  final String title;
  final DateTime Function()? getSelectedDate;
  final Function(DateTime)? onChanged;

  const MonthPickerFormField({
    Key? key,
    this.controller,
    this.initialValue,
    this.buttonStyle,
    this.currentDateStyle,
    this.selectedDateStyle,
    this.title = '',
    this.getSelectedDate,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(context) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: title),
        initialValue: initialValue,
        focusNode: AlwaysDisabledFocusNode(),
        onTap: () => showDialog(
              context: context,
              builder: (ctx) {
                DateTime _selectedDate = getSelectedDate == null
                    ? DateTime.now().toUtc()
                    : getSelectedDate!();
                return AlertDialog(
                  shape: PassyTheme.dialogShape,
                  title: Text(title),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          localizations.cancel,
                          style: buttonStyle ??
                              TextStyle(
                                  color: PassyTheme.of(context)
                                      .highlightContentSecondaryColor),
                        )),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, _selectedDate),
                        child: Text(
                          localizations.confirm,
                          style: buttonStyle ??
                              TextStyle(
                                  color: PassyTheme.of(context)
                                      .highlightContentSecondaryColor),
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
                            currentDateStyle: currentDateStyle ??
                                TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor),
                            selectedDateStyle: selectedDateStyle ??
                                TextStyle(
                                    color: PassyTheme.of(context)
                                        .highlightContentSecondaryColor)),
                      );
                    },
                  ),
                );
              },
            ).then((value) {
              if (onChanged == null) return;
              if (value == null) return;
              onChanged!(value);
            }));
  }
}
