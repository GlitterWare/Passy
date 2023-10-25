import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class FileButtonListView extends StatelessWidget {
  final List<FileEntry> files;
  final bool shouldSort;
  final void Function(FileEntry file)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, FileEntry file)? popupMenuItemBuilder;
  final Widget Function(BuildContext context, FileEntry file)? buttonBuilder;
  final List<Widget>? topWidgets;

  const FileButtonListView({
    Key? key,
    required this.files,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.buttonBuilder,
    this.topWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortFiles(files);
    return ListView(
      shrinkWrap: true,
      children: [
        if (topWidgets != null) ...topWidgets!,
        for (FileEntry file in files)
          Row(
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          PassyTheme.passyPadding.left,
                          PassyTheme.passyPadding.top,
                          0,
                          PassyTheme.passyPadding.bottom),
                      child: FileButton(
                        file: file,
                        onPressed:
                            onPressed == null ? null : () => onPressed!(file),
                        popupMenuItemBuilder: popupMenuItemBuilder == null
                            ? null
                            : (context) => popupMenuItemBuilder!(context, file),
                      ))),
              if (buttonBuilder != null)
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        0,
                        PassyTheme.passyPadding.top,
                        PassyTheme.passyPadding.right,
                        PassyTheme.passyPadding.bottom),
                    child: buttonBuilder!.call(context, file)),
            ],
          ),
      ],
    );
  }
}
