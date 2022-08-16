import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/screens/edit_note_screen.dart';
import 'package:passy/screens/notes_screen.dart';
import 'package:passy/screens/theme.dart';

import 'common.dart';
import 'main_screen.dart';

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
            shape: dialogShape,
            title: const Text('Remove note'),
            content: const Text('Notes can only be restored from a backup.'),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style: TextStyle(color: lightContentSecondaryColor),
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

  @override
  Widget build(BuildContext context) {
    final Note _note = ModalRoute.of(context)!.settings.arguments as Note;
    return Scaffold(
      appBar: AppBar(
        leading: getBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _onRemovePressed(_note),
          ),
          IconButton(
            padding: appBarButtonPadding,
            splashRadius: appBarButtonSplashRadius,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditNoteScreen.routeName,
                arguments: _note,
              );
            },
          ),
        ],
        title: const Center(child: Text('Note')),
      ),
      body: ListView(children: [
        if (_note.title != '') buildRecord(context, 'Title', _note.title),
        if (_note.note != '')
          buildRecord(context, 'Note', _note.note, valueAlign: TextAlign.left),
      ]),
    );
  }
}
