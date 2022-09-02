import 'package:flutter/material.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class CustomFieldEditorListView extends StatefulWidget {
  final List<CustomField> customFields;
  final bool shouldSort;
  final EdgeInsetsGeometry padding;
  final ColorScheme? datePickerColorScheme;

  const CustomFieldEditorListView({
    Key? key,
    required this.customFields,
    this.shouldSort = true,
    this.padding = EdgeInsets.zero,
    this.datePickerColorScheme = PassyTheme.datePickerColorScheme,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFieldEditorListView();
}

class _CustomFieldEditorListView extends State<CustomFieldEditorListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        CustomField _customField = super.widget.customFields[index];
        return Padding(
          padding: super.widget.padding,
          child: CustomFieldEditor(
            customField: _customField,
            onChanged: (value) => setState(() => _customField.value = value),
            onRemovePressed: () =>
                setState(() => super.widget.customFields.removeAt(index)),
            datePickerColorScheme: super.widget.datePickerColorScheme,
          ),
        );
      },
      itemCount: super.widget.customFields.length,
    );
  }
}
