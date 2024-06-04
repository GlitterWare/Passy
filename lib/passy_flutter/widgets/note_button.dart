import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButton extends StatelessWidget {
  final Widget? leftWidget;
  final NoteMeta note;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const NoteButton({
    Key? key,
    this.leftWidget,
    required this.note,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
      if (leftWidget != null) leftWidget!,
        Flexible(
          child: ThreeWidgetButton(
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.note_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  child: Text(
                    note.title,
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
