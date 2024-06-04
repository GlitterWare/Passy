import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/sync_entry_state.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButtonListView extends StatelessWidget {
  final List<NoteMeta> notes;
  final bool shouldSort;
  final void Function(NoteMeta note)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, NoteMeta noteMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;
  final Map<String, SyncEntryState> syncStates;

  const NoteButtonListView({
    Key? key,
    required this.notes,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
    Map<String, SyncEntryState>? syncStates,
  })  : syncStates = syncStates ?? const {},
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortNotes(notes);
    List<Widget> _entriesWidgets = [];
    for (NoteMeta note in notes) {
      SyncEntryState? state = syncStates[note.key];
      Widget? stateIcon;
      switch (state) {
        case null:
          break;
        case SyncEntryState.added:
          stateIcon = const Icon(Icons.add, color: Colors.green, size: 28);
          break;
        case SyncEntryState.removed:
          stateIcon = const Icon(Icons.delete_rounded,
              color: Colors.red, size: 28);
          break;
        case SyncEntryState.modified:
          stateIcon = const Icon(Icons.edit, color: Colors.yellow, size: 28);
          break;
      }
      _entriesWidgets.add(PassyPadding(NoteButton(
        leftWidget: stateIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  PassyTheme.passyPadding.left,
                  PassyTheme.passyPadding.top,
                  PassyTheme.passyPadding.right * 2,
                  PassyTheme.passyPadding.bottom,
                ),
                child: stateIcon,
              ),
        note: note,
        onPressed: onPressed == null ? null : () => onPressed!(note),
        popupMenuItemBuilder: popupMenuItemBuilder == null
            ? null
            : (context) => popupMenuItemBuilder!(context, note),
      )));
    }
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        ..._entriesWidgets,
      ],
    );
  }
}
