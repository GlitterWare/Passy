import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/passy_file_screen.dart';

class AttachmentsEditor extends StatefulWidget {
  final List<String> files;
  final void Function(String key)? onFileAdded;
  final void Function(String key)? onFileRemoved;

  const AttachmentsEditor({
    super.key,
    required this.files,
    this.onFileAdded,
    this.onFileRemoved,
  });

  @override
  State<StatefulWidget> createState() => _AttachmentsEditor();
}

class _AttachmentsEditor extends State<AttachmentsEditor> {
  final LoadedAccount _account = data.loadedAccount!;
  bool _isLoaded = false;
  List<Widget>? _attachments;

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _attachments = null);
    Map<String, PassyFsMeta> fsEntries =
        await _account.getFsEntries(widget.files);
    List<FileMeta> meta = fsEntries.values.map((e) => e as FileMeta).toList();
    for (String key in widget.files) {
      if (fsEntries.containsKey(key)) continue;
      meta.add(FileMeta(
        key: key,
        name: localizations.missingFile,
        virtualPath: 'NULL',
        path: 'NULL',
        changed: DateTime.fromMicrosecondsSinceEpoch(0),
        modified: DateTime.fromMicrosecondsSinceEpoch(0),
        accessed: DateTime.fromMicrosecondsSinceEpoch(0),
        size: 0,
        type: PassyFileType.unknown,
      ));
    }
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
            buttonBuilder: (context, file) => SizedBox(
              height: 43,
              child: FloatingActionButton(
                heroTag: null,
                tooltip: localizations.remove,
                child: const Icon(Icons.remove_rounded),
                onPressed: () {
                  widget.onFileRemoved?.call(file.key);
                  _refresh();
                },
              ),
            ),
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
      children: _attachments == null && widget.files.isNotEmpty
          ? const [
              Center(
                child: CircularProgressIndicator(
                  color: PassyTheme.lightContentColor,
                ),
              ),
            ]
          : [
              PassyPadding(
                ThreeWidgetButton(
                  left: const Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Icon(Icons.file_open_outlined)),
                  center: Text(localizations.attachFile),
                  right: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pushNamed(context, FilesScreen.routeName,
                            arguments: FilesScreenArgs(
                                path: '/sync/attach', attach: true))
                        .then((value) {
                      if (value is! FilesScreenResult) return _refresh();
                      if (widget.files.contains(value.key)) return _refresh();
                      widget.onFileAdded?.call(value.key);
                      _refresh();
                    });
                  },
                ),
              ),
              if (_attachments != null) ..._attachments!,
            ],
    );
  }
}
