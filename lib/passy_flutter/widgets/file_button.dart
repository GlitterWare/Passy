import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class FileButton extends StatelessWidget {
  final FileEntry file;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const FileButton({
    Key? key,
    required this.file,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  Widget _buildIcon(BuildContext context, FileEntryType type) {
    Widget? icon = file.icon;
    if (icon != null) return icon;
    switch (type) {
      case FileEntryType.unknown:
        return const Icon(Icons.file_open_outlined);
      case FileEntryType.folder:
        return const Icon(Icons.folder);
      case FileEntryType.file:
        return const Icon(Icons.file_open_outlined);
      case FileEntryType.plainText:
        return const Icon(Icons.description_outlined);
      case FileEntryType.markdown:
        return SvgPicture.asset(
          'assets/images/file-markdown-svgrepo-com.svg',
          width: 26,
          colorFilter: ColorFilter.mode(
              PassyTheme.of(context).highlightContentColor, BlendMode.srcIn),
        );
      case FileEntryType.photo:
        return const Icon(Icons.image_outlined);
      case FileEntryType.audio:
        return const Icon(Icons.music_note);
      case FileEntryType.video:
        return const Icon(Icons.video_file_outlined);
      case FileEntryType.pdf:
        return SvgPicture.asset(
          'assets/images/pdf-file.svg',
          width: 26,
          colorFilter: ColorFilter.mode(
              PassyTheme.of(context).highlightContentColor, BlendMode.srcIn),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = _buildIcon(context, file.type);
    return Row(
      children: [
        Flexible(
          child: ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: icon,
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  child: Text(
                    file.name,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
          ),
        ),
        if (popupMenuItemBuilder != null)
          FittedBox(
            child: PopupMenuButton(
              shape: PassyTheme.dialogShape,
              icon: const Icon(Icons.more_vert_rounded),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              splashRadius: 24,
              itemBuilder: popupMenuItemBuilder!,
            ),
          ),
      ],
    );
  }
}
