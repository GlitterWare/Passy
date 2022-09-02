import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'main_screen.dart';
import 'edit_note_screen.dart';
import 'notes_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const routeName = '/note';

  @override
  State<StatefulWidget> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  void _onRemovePressed(Note note) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: const Text('Remove note'),
            content: const Text('Notes can only be restored from a backup.'),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  _account.removeNote(note.key);
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  _account.save().whenComplete(() =>
                      Navigator.pushNamed(context, NotesScreen.routeName));
                },
              )
            ],
          );
        });
  }

  void _onEditPressed(Note note) {
    Navigator.pushNamed(
      context,
      EditNoteScreen.routeName,
      arguments: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Note _note = ModalRoute.of(context)!.settings.arguments as Note;
    return Scaffold(
      appBar: EntryScreenAppBar(
        title: const Center(child: Text('Note')),
        onRemovePressed: () => _onRemovePressed(_note),
        onEditPressed: () => _onEditPressed(_note),
      ),
      body: ListView(children: [
        if (_note.title != '')
          PassyPadding(PassyRecord(title: 'Title', value: _note.title)),
        if (_note.note != '')
          PassyPadding(PassyRecord(
            title: 'Note',
            value: _note.note,
            valueAlign: TextAlign.left,
          )),
      ]),
    );
  }
}
