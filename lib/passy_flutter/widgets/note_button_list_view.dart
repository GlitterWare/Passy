import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButtonListView extends StatelessWidget {
  final List<Note> notes;
  final bool shouldSort;
  final void Function(Note note)? onPressed;

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
        for (Note note in notes)
          PassyPadding(NoteButton(
            note: note,
            onPressed: () => onPressed?.call(note),
          )),
      ],
    );
  }
}
