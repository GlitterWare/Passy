import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class RenameFileDialog extends StatefulWidget {
  final String name;

  const RenameFileDialog({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RenameFileDialog();
}

class _RenameFileDialog extends State<RenameFileDialog> {
  String _value = '';

  void _onNameChanged(String val) {
    setState(() => _value = val);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: PassyTheme.dialogShape,
      child: ListView(
        shrinkWrap: true,
        children: [
          PassyPadding(TextFormField(
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[\\\/:*?"<>|]'))
            ],
            decoration: InputDecoration(labelText: localizations.fileName),
            initialValue: _value,
            maxLines: 1,
            onChanged: _onNameChanged,
            onFieldSubmitted: (value) => Navigator.pop(
                context,
                (_value == '' || _value == '.' || _value == '..')
                    ? null
                    : _value),
          )),
          Row(
            children: [
              const Spacer(),
              PassyPadding(
                FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.cancel,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded),
                ),
              ),
              PassyPadding(
                FloatingActionButton(
                  heroTag: null,
                  tooltip: localizations.rename,
                  onPressed: () =>
                      Navigator.pop(context, _value.isEmpty ? null : _value),
                  child: const Icon(Icons.check_rounded),
                ),
              ),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
