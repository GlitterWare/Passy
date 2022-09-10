import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class CustomFieldEditorListView extends StatefulWidget {
  final List<CustomField> customFields;
  final bool shouldSort;
  final EdgeInsetsGeometry padding;
  final ColorScheme? datePickerColorScheme;
  final Future<CustomField?> Function() buildCustomField;

  const CustomFieldEditorListView({
    Key? key,
    required this.customFields,
    this.shouldSort = false,
    this.padding = EdgeInsets.zero,
    this.datePickerColorScheme = PassyTheme.datePickerColorScheme,
    required this.buildCustomField,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFieldEditorListView();
}

class _CustomFieldEditorListView extends State<CustomFieldEditorListView> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldSort) PassySort.sortCustomFields(widget.customFields);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PassyPadding(ThreeWidgetButton(
          left: const Padding(
            padding: EdgeInsets.only(right: 30),
            child: Icon(Icons.add_rounded),
          ),
          center: const Text('Add custom field'),
          onPressed: () {
            widget.buildCustomField().then((value) {
              if (value != null) {
                setState(() {
                  widget.customFields.add(value);
                  PassySort.sortCustomFields(widget.customFields);
                });
              }
            });
          },
        )),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.customFields.length,
          itemBuilder: (context, index) {
            List<TextInputFormatter>? _inputFormatters;
            FocusNode? _focusNode;
            void Function()? _onTap;
            CustomField _field = widget.customFields[index];
            switch (_field.fieldType) {
              case (FieldType.number):
                _inputFormatters = [FilteringTextInputFormatter.digitsOnly];
                break;
              case (FieldType.date):
                _focusNode = AlwaysDisabledFocusNode();
                _onTap = () {
                  showPassyDatePicker(
                    context: context,
                    date: _field.value == ''
                        ? DateTime.now()
                        : stringToDate(_field.value),
                  ).then((value) {
                    if (value == null) return;
                    setState(() => _field.value = dateToString(value));
                  });
                };
                break;
              default:
                break;
            }
            return Padding(
              padding: widget.padding,
              child: ButtonedTextFormField(
                key: UniqueKey(),
                focusNode: _focusNode,
                initialValue: _field.value,
                labelText: _field.title,
                buttonIcon: const Icon(Icons.remove_rounded),
                onChanged: (value) => _field.value = value,
                onTap: _onTap,
                onPressed: () => setState(
                  () => widget.customFields.removeAt(index),
                ),
                inputFormatters: _inputFormatters,
              ),
            );
          },
        ),
      ],
    );
  }
}
