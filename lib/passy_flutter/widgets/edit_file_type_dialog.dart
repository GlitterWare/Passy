import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EditFileTypeDialog extends StatefulWidget {
  final FileEntryType type;

  const EditFileTypeDialog({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditFileTypeDialog();
}

class _EditFileTypeDialog extends State<EditFileTypeDialog> {
  FileEntryType _value = FileEntryType.file;

  void _onValueChanged(FileEntryType val) {
    setState(() => _value = val);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: PassyTheme.dialogShape,
      child: ListView(
        shrinkWrap: true,
        children: [
          PassyPadding(
            EnumDropDownButtonFormField<FileEntryType>(
              value: _value,
              decoration: InputDecoration(labelText: localizations.fileType),
              values: const [
                FileEntryType.photo,
                FileEntryType.audio,
                FileEntryType.video,
                FileEntryType.plainText,
                FileEntryType.markdown,
                FileEntryType.unknown,
              ],
              itemBuilder: (object) {
                switch (object) {
                  case FileEntryType.folder:
                    return Text(localizations.folder);
                  case FileEntryType.plainText:
                    return Text(localizations.plainText);
                  case FileEntryType.markdown:
                    return Text(localizations.markdown);
                  case FileEntryType.photo:
                    return Text(localizations.photo);
                  case FileEntryType.file:
                    return Text(localizations.unknown);
                  case FileEntryType.unknown:
                    return Text(localizations.unknown);
                  case FileEntryType.audio:
                    return Text(localizations.audio);
                  case FileEntryType.video:
                    return Text(localizations.video);
                  case FileEntryType.pdf:
                    return const Text('PDF');
                }
              },
              onChanged: (value) {
                if (value == null) return;
                _onValueChanged(value);
              },
            ),
          ),
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
                  tooltip: localizations.fileType,
                  onPressed: () => Navigator.pop(context, _value),
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
