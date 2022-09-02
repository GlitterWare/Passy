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
    this.shouldSort = false,
    this.padding = EdgeInsets.zero,
    this.datePickerColorScheme = PassyTheme.datePickerColorScheme,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomFieldEditorListView();
}

class _CustomFieldEditorListView extends State<CustomFieldEditorListView> {
  late List<CustomField> customFields;

  @override
  void initState() {
    super.initState();
    customFields = widget.customFields;
    if (widget.shouldSort) PassySort.sortCustomFields(customFields);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        for (int i = 0; i != customFields.length; i++)
          Padding(
            padding: widget.padding,
            child: CustomFieldEditor(
              customField: widget.customFields[i],
              onChanged: (value) =>
                  setState(() => customFields[i].value = value),
              onRemovePressed: () => setState(() => customFields.removeAt(i)),
              datePickerColorScheme: widget.datePickerColorScheme,
            ),
          ),
      ],
    );
  }
}
