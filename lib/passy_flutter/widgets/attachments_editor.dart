import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/passy_file_screen.dart';

class AttachmentsEditor extends StatefulWidget {
  final List<String> files;

  const AttachmentsEditor({super.key, required this.files});

  @override
  State<StatefulWidget> createState() => _AttachmentsEditor();
}

class _AttachmentsEditor extends State<AttachmentsEditor> {
  final LoadedAccount _account = data.loadedAccount!;
  bool _isLoaded = false;
  List<String> _files = [];
  List<Widget>? _attachments;

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _attachments = null);
    List<FileMeta> meta = (await _account.getFsEntries(_files))
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
            buttonBuilder: (context, file) => SizedBox(
              height: 43,
              child: FloatingActionButton(
                heroTag: null,
                tooltip: localizations.remove,
                child: const Icon(Icons.remove_rounded),
                onPressed: () {
                  _files.remove(file.key);
                  _refresh();
                },
              ),
            ),
          ),
        ]);
  }

  @override
  void initState() {
    super.initState();
    _files = List<String>.from(widget.files);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      _isLoaded = true;
      _refresh();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _attachments == null && _files.isNotEmpty
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
                      if (_files.contains(value.key)) return _refresh();
                      _files.add(value.key);
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
