import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class AddFolderDialog extends StatefulWidget {
  const AddFolderDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFolderDialog();
}

class _AddFolderDialog extends State<AddFolderDialog> {
  String _value = '';

  void _onNameChanged(String val) {
    setState(() => _value = val);
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
            decoration: InputDecoration(labelText: localizations.folderName),
            initialValue: _value,
            maxLines: 1,
            onChanged: _onNameChanged,
            onFieldSubmitted: (value) => Navigator.pop(
                context, prohibitedFileNames.contains(_value) ? null : _value),
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
                  tooltip: localizations.done,
                  onPressed: () => Navigator.pop(context,
                      prohibitedFileNames.contains(_value) ? null : _value),
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
