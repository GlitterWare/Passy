import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'main_screen.dart';
import 'note_screen.dart';
import 'search_screen.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/notes';

  @override
  State<StatefulWidget> createState() => _NotesScreen();
}

class _NotesScreen extends State<NotesScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditNoteScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: (String terms) {
      final List<NoteMeta> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (NoteMeta _note in _account.notesMetadata.values) {
        {
          bool testNote(NoteMeta value) => _note.key == value.key;

          if (_found.any(testNote)) continue;
        }
        {
          int _positiveCount = 0;
          for (String _term in _terms) {
            if (_note.title.toLowerCase().contains(_term)) {
              _positiveCount++;
              continue;
            }
          }
          if (_positiveCount == _terms.length) {
            _found.add(_note);
          }
        }
      }
      return NoteButtonListView(
        notes: _found,
        shouldSort: true,
        onPressed: (note) => Navigator.pushNamed(context, NoteScreen.routeName,
            arguments: _account.getNote(note.key)),
        popupMenuItemBuilder: notePopupMenuBuilder,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    List<NoteMeta> _notes = _account.notesMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
          title: const Center(child: Text('Notes')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _notes.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      const Text(
                        'No notes',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditNoteScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : NoteButtonListView(
              notes: _notes,
              shouldSort: true,
              onPressed: (note) => Navigator.pushNamed(
                  context, NoteScreen.routeName,
                  arguments: _account.getNote(note.key)),
              popupMenuItemBuilder: notePopupMenuBuilder,
            ),
    );
  }
}
