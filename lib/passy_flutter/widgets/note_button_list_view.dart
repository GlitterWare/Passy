import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButtonListView extends StatelessWidget {
  final List<NoteMeta> notes;
  final bool shouldSort;
  final void Function(NoteMeta note)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, NoteMeta noteMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;

  const NoteButtonListView({
    Key? key,
    required this.notes,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortNotes(notes);
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        for (NoteMeta note in notes)
          PassyPadding(NoteButton(
            note: note,
            onPressed: onPressed == null ? null : () => onPressed!(note),
            popupMenuItemBuilder: popupMenuItemBuilder == null
                ? null
                : (context) => popupMenuItemBuilder!(context, note),
          )),
      ],
    );
  }
}
