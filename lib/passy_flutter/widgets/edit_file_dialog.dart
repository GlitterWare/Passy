import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EditFileDialogResponse {
  final String name;
  final FileEntryType type;

  EditFileDialogResponse({required this.name, required this.type});
}

class EditFileDialog extends StatefulWidget {
  final String name;
  final FileEntryType type;

  const EditFileDialog({
    Key? key,
    required this.name,
    required this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditFileDialog();
}

class _EditFileDialog extends State<EditFileDialog> {
  String _name = '';
  FileEntryType _type = FileEntryType.file;

  void _onNameChanged(String val) {
    setState(() => _name = val);
  }

  void _onTypeChanged(FileEntryType val) {
    setState(() => _type = val);
  }

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _type =
        widget.type == FileEntryType.file ? FileEntryType.unknown : widget.type;
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
            initialValue: _name,
            maxLines: 1,
            onChanged: _onNameChanged,
          )),
          PassyPadding(
            EnumDropDownButtonFormField<FileEntryType>(
              value: _type,
              decoration: InputDecoration(labelText: localizations.fileType),
              values: const [
                FileEntryType.photo,
                FileEntryType.audio,
                FileEntryType.video,
                FileEntryType.plainText,
                FileEntryType.markdown,
                FileEntryType.pdf,
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
                _onTypeChanged(value);
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
                  tooltip: localizations.save,
                  onPressed: () {
                    if (prohibitedFileNames.contains(_name)) {
                      Navigator.pop(context);
                      return;
                    }
                    Navigator.pop(context,
                        EditFileDialogResponse(name: _name, type: _type));
                  },
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
