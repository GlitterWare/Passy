import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/passy_file_screen.dart';

class AttachmentsListView extends StatefulWidget {
  final List<String> files;

  const AttachmentsListView({
    super.key,
    required this.files,
  });

  @override
  State<StatefulWidget> createState() => _AttachmentsListView();
}

class _AttachmentsListView extends State<AttachmentsListView> {
  final LoadedAccount _account = data.loadedAccount!;
  bool _isLoaded = false;
  List<Widget>? _attachments;

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _attachments = null);
    List<FileMeta> meta = (await _account.getFsEntries(widget.files))
        .values
        .map((e) => e as FileMeta)
        .toList();
    if (!mounted) return;
    setState(() => _attachments = [
          FileButtonListView(
            files: meta
                .map((e) => FileEntry(
                      key: e.key,
                      path: e.virtualPath,
                      name: e.name,
                      type: fileEntryTypeFromPassyFileType(e.type),
                    ))
                .toList(),
            onPressed: (file) {
              Navigator.pushNamed(
                context,
                PassyFileScreen.routeName,
                arguments: PassyFileScreenArgs(
                  title: file.name,
                  key: file.key,
                  type: file.type,
                ),
              );
            },
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      _isLoaded = true;
      _refresh();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _attachments == null
          ? [
              Center(
                child: CircularProgressIndicator(
                  color: PassyTheme.of(context).contentTextColor,
                ),
              ),
            ]
          : _attachments!,
    );
  }
}
