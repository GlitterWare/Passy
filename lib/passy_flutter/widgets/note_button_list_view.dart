import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButtonListView extends StatelessWidget {
  final List<NoteMeta> notes;
  final bool shouldSort;
  final void Function(NoteMeta note)? onPressed;

  const NoteButtonListView({
    Key? key,
    required this.notes,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortNotes(notes);
    return ListView(
      children: [
        for (NoteMeta note in notes)
          PassyPadding(NoteButton(
            note: note,
            onPressed: () => onPressed?.call(note),
          )),
      ],
    );
  }
}
