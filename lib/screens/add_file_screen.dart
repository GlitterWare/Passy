import 'dart:io';

import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/file_meta.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:path/path.dart';

import 'common.dart';
import 'files_screen.dart';
import 'log_screen.dart';

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({Key? key}) : super(key: key);

  static const String routeName = '${FilesScreen.routeName}/add';

  @override
  State<StatefulWidget> createState() => _AddFileScreen();
}

class AddFileScreenArgs {
  final File file;
  final String parent;
  FileEntryType type;

  AddFileScreenArgs({
    required this.file,
    required this.parent,
    required this.type,
  });
}

class _AddFileScreen extends State<AddFileScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  bool isLoaded = false;
  FileMeta? _fileMeta;
  GlobalKey _previewKey = GlobalKey();
  Widget? _preview;

  Future<void> _load(BuildContext context, AddFileScreenArgs args) async {
    FileMeta newFileMeta =
        await FileMeta.fromFile(args.file, virtualParent: args.parent);
    switch (args.type) {
      case FileEntryType.plainText:
        newFileMeta.type = PassyFileType.text;
        break;
      case FileEntryType.markdown:
        newFileMeta.type = PassyFileType.markdown;
        break;
      case FileEntryType.photo:
        newFileMeta.type = PassyFileType.photo;
        break;
      case FileEntryType.unknown:
        args.type = fileEntryTypeFromPassyFileType(newFileMeta.type);
        break;
      case FileEntryType.file:
        args.type = fileEntryTypeFromPassyFileType(newFileMeta.type);
        break;
      case FileEntryType.folder:
        break;
    }
    setState(() {
      _fileMeta = newFileMeta;
      _preview = PassyFileWidget(
          path: args.file.path,
          name: basename(args.file.path),
          isEncrypted: false,
          type: args.type);
      _previewKey = GlobalKey();
    });
  }

  Future<void> _onAddPressed(
      BuildContext context, AddFileScreenArgs args) async {
    Navigator.pushNamed(context, SplashScreen.routeName);
    try {
      await _account.addFile(args.file, useIsolate: true, meta: _fileMeta);
    } catch (e, s) {
      showSnackBar(
        context,
        message: localizations.failedToAddFile,
        icon:
            const Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(
              navigatorKey.currentContext!, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    AddFileScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as AddFileScreenArgs;
    if (!isLoaded) {
      isLoaded = true;
      _load(context, args);
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(basename(args.file.path)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              children: _fileMeta == null
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
                      const Spacer(),
                      if (_preview != null)
                        Flexible(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${localizations.filePreview}:',
                                style: const TextStyle(
                                    color:
                                        PassyTheme.lightContentSecondaryColor),
                              ),
                              Flexible(
                                  flex: 10,
                                  child: PassyPadding(Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        width: 10,
                                        color: PassyTheme
                                            .darkContentSecondaryColor,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      key: _previewKey,
                                      borderRadius: BorderRadius.circular(9),
                                      clipBehavior: Clip.antiAlias,
                                      child: _preview,
                                    ),
                                  ))),
                            ],
                          ),
                        ),
                      if (_preview != null) const Spacer(),
                      PassyPadding(EnumDropDownButtonFormField<FileEntryType>(
                        value: args.type,
                        decoration:
                            InputDecoration(labelText: localizations.fileType),
                        values: const [
                          FileEntryType.photo,
                          FileEntryType.plainText,
                          FileEntryType.markdown,
                          FileEntryType.unknown,
                        ],
                        itemBuilder: (object) {
                          switch (object) {
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
                            case FileEntryType.folder:
                              return Text(localizations.folder);
                          }
                        },
                        onChanged: (value) {
                          if (value == null) return;
                          args.type = value;
                          _load(context, args);
                        },
                      )),
                      Text.rich(
                        TextSpan(
                          text: '${localizations.fileSize}: ',
                          children: [
                            TextSpan(
                              text: _fileMeta!.size < 1048576
                                  ? '${(_fileMeta!.size / 1024).round()} kB'
                                  : '${(_fileMeta!.size / 1048576).round()} MB',
                              style: TextStyle(
                                  color: _fileMeta!.size < 9961472
                                      ? Colors.green
                                      : (_fileMeta!.size < 15204352
                                          ? Colors.amber
                                          : Colors.red)),
                            ),
                          ],
                        ),
                      ),
                      PassyPadding(ThreeWidgetButton(
                        left: const Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Icon(Icons.add_rounded)),
                        center: Center(child: Text(localizations.addFile)),
                        right: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () => _onAddPressed(context, args),
                      )),
                      const Spacer(),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
