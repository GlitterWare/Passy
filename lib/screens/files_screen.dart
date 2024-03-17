import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_data/passy_fs_meta.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/add_file_screen.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/passy_file_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'main_screen.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/files';

  @override
  State<StatefulWidget> createState() => _FilesScreen();
}

class FilesScreenArgs {
  final String path;
  final bool attach;

  FilesScreenArgs({
    this.path = '/',
    this.attach = false,
  });
}

class FilesScreenResult {
  final String key;

  FilesScreenResult({
    required this.key,
  });
}

class _FilesScreen extends State<FilesScreen> {
  final _account = data.loadedAccount!;
  String? _title;
  List<FileEntry>? _files;

  Future<List<FileEntry>> listFiles(String path) async {
    Iterable<PassyFsMeta> filesMeta = (await _account.getFsMetadata()).values;
    List<FileEntry> result = [];
    List<String> folders = [];
    List<String> selfPathSplit;
    if (path == '/') {
      selfPathSplit = [''];
    } else {
      selfPathSplit = path.split('/');
    }
    bool namedDirectoriesAdded = path != '/' && path != '/sync';
    for (dynamic meta in filesMeta) {
      meta = meta as FileMeta;
      List<String> filePathSplit = meta.virtualPath.split('/');
      bool wrongPath = false;
      for (int i = 0; i != selfPathSplit.length; i++) {
        if (selfPathSplit[i] != filePathSplit[i]) {
          wrongPath = true;
          break;
        }
      }
      if (wrongPath) continue;
      if (selfPathSplit.length != filePathSplit.length - 1) {
        String folderPath =
            filePathSplit.sublist(0, selfPathSplit.length + 1).join('/');
        if (folders.contains(folderPath)) continue;
        folders.add(folderPath);
        String name;
        if (folderPath == '/sync') {
          namedDirectoriesAdded = true;
          name = localizations.synchronizedFiles;
        } else if (folderPath == '/sync/attach') {
          namedDirectoriesAdded = true;
          name = localizations.attachments;
        } else {
          name = filePathSplit[selfPathSplit.length];
        }
        result.add(FileEntry(
          key: '',
          path: folderPath,
          name: name,
          type: FileEntryType.folder,
        ));
        continue;
      }
      FileEntryType type;
      switch (meta.type) {
        case PassyFileType.unknown:
          type = FileEntryType.file;
          break;
        case PassyFileType.text:
          type = FileEntryType.plainText;
          break;
        case PassyFileType.markdown:
          type = FileEntryType.markdown;
          break;
        case PassyFileType.photo:
          type = FileEntryType.photo;
          break;
      }
      result.add(FileEntry(
        key: meta.key,
        path: meta.virtualPath,
        name: meta.name,
        type: type,
      ));
    }
    if (!namedDirectoriesAdded) {
      String name;
      String vPath;
      if (path == '/') {
        name = localizations.synchronizedFiles;
        vPath = '/sync';
        namedDirectoriesAdded = true;
      } else {
        name = localizations.attachments;
        vPath = '/sync/attach';
        namedDirectoriesAdded = true;
      }
      result.add(FileEntry(
        key: '',
        path: vPath,
        name: name,
        type: FileEntryType.folder,
      ));
    }
    return result;
  }

  void _push(FilesScreenArgs args, BuildContext context, String screenName,
      dynamic screenArgs) {
    if (screenName == PassyFileScreen.routeName) {
      if (args.attach) {
        FilesScreenResult result =
            FilesScreenResult(key: (screenArgs as PassyFileScreenArgs).key);
        Navigator.pop(context, result);
        return;
      }
    }
    Navigator.pushNamed(context, screenName, arguments: screenArgs)
        .then((value) async {
      _files = await listFiles(args.path);
      if (!mounted) return;
      setState(() {});

      if (value == null) return;
      switch (screenName) {
        case FilesScreen.routeName:
          if (value is! FilesScreenResult) return;
          Navigator.pop(context, value);
          return;
        case AddFileScreen.routeName:
          if (value is! AddFileScreenResult) return;
          if (args.attach) {
            Navigator.pop(context, FilesScreenResult(key: value.key));
            return;
          }
          Navigator.pushNamed(context, PassyFileScreen.routeName,
              arguments: PassyFileScreenArgs(
                  title: value.title,
                  key: value.key,
                  type: fileEntryTypeFromPassyFileType(value.type)));
          return;
      }
      return;
    });
  }

  Future<void> _onAddFilePressed(FilesScreenArgs args,
      {FileEntryType type = FileEntryType.file}) async {
    UnlockScreen.shouldLockScreen = false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: localizations.addFile,
      lockParentWindow: true,
    );
    Future.delayed(const Duration(seconds: 2))
        .then((value) => UnlockScreen.shouldLockScreen = true);
    if (result == null) return;
    if (result.files.isEmpty) return;
    File file = File(result.files[0].path!);
    _push(
      args,
      context,
      AddFileScreen.routeName,
      AddFileScreenArgs(file: file, parent: args.path, type: type),
    );
  }

  void _onOpenFolderPressed(FilesScreenArgs args, String? path) async {
    if (path == null) {
      path = await showDialog(
          context: context, builder: (context) => const AddFolderDialog());
      if (path == null) return;
    }
    if (!path.startsWith('/')) {
      if (path.startsWith('./')) {
        if (path.length == 2) return;
        path = path.substring(2);
      } else {
        path = '${args.path == '/' ? '' : args.path}/$path';
      }
    }
    _push(
      args,
      context,
      FilesScreen.routeName,
      FilesScreenArgs(path: path, attach: args.attach),
    );
  }

  @override
  Widget build(BuildContext context) {
    FilesScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as FilesScreenArgs? ??
            FilesScreenArgs();
    if (_title == null) {
      if (args.path == '/sync') {
        _title = localizations.synchronizedFiles;
      } else if (args.path == '/sync/attach') {
        _title = localizations.attachments;
      } else {
        _title ??=
            args.path == '/' ? localizations.files : args.path.split('/').last;
      }
      listFiles(args.path).then((value) => setState(() => _files = value));
    }

    Widget addDropdown = EnumDropdownButton2<FileEntryType>(
      isExpanded: true,
      alignment: Alignment.centerRight,
      items: [
        EnumDropdownButton2Item(
          value: FileEntryType.unknown,
          text: Text(
            '${localizations.add}...',
            textAlign: TextAlign.center,
          ),
          icon: const Icon(Icons.add_rounded),
        ),
        EnumDropdownButton2Item(
          value: FileEntryType.file,
          text: Text(
            localizations.file,
            textAlign: TextAlign.center,
          ),
          icon: const Icon(Icons.file_open_outlined),
        ),
        EnumDropdownButton2Item(
          value: FileEntryType.folder,
          text: Text(
            localizations.folder,
            textAlign: TextAlign.center,
          ),
          icon: const Icon(Icons.folder),
        ),
      ],
      value: FileEntryType.unknown,
      onChanged: (value) {
        if (value == null) return;
        switch (value) {
          case FileEntryType.folder:
            _onOpenFolderPressed(args, null);
            return;
          default:
            _onAddFilePressed(args);
            return;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_title!),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: localizations.add,
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: [
                      const PassyPadding(Icon(Icons.close_rounded)),
                      PassyPadding(Text(localizations.cancel)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const PassyPadding(Icon(Icons.file_open_outlined)),
                      PassyPadding(Text(localizations.file)),
                    ],
                  ),
                  onTap: () => _onAddFilePressed(args),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const PassyPadding(Icon(Icons.folder)),
                      PassyPadding(Text(localizations.folder)),
                    ],
                  ),
                  onTap: () => _onOpenFolderPressed(args, null),
                ),
              ];
            },
          )
        ],
      ),
      body: (_files?.isEmpty ?? true)
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: _files == null
                        ? const [
                            Spacer(),
                            Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: PassyTheme.lightContentColor,
                                ),
                              ),
                            ),
                            Spacer(),
                          ]
                        : [
                            const Spacer(flex: 7),
                            Text(
                              '${localizations.noFiles}.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            addDropdown,
                            const Spacer(flex: 7),
                          ],
                  ),
                ),
              ],
            )
          : FileButtonListView(
              topWidgets: [addDropdown],
              files: _files!,
              shouldSort: true,
              onPressed: (file) {
                switch (file.type) {
                  case FileEntryType.folder:
                    _onOpenFolderPressed(
                        args, file.path.split(Platform.pathSeparator).last);
                    return;
                  default:
                    _push(
                      args,
                      context,
                      PassyFileScreen.routeName,
                      PassyFileScreenArgs(
                        title: file.name,
                        key: file.key,
                        type: file.type,
                      ),
                    );
                }
              },
              popupMenuItemBuilder: (context, file) => filePopupMenuBuilder(
                context,
                file,
                onChanged: () async {
                  _files = await listFiles(args.path);
                  if (!mounted) return;
                  setState(() {});
                },
              ),
            ),
    );
  }
}
