import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/screens/edit_note_screen.dart';

import 'common.dart';
import 'theme.dart';
import 'main_screen.dart';
import 'search_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/notes';

  @override
  State<StatefulWidget> createState() => _NotesScreen();
}

class _NotesScreen extends State<NotesScreen> {
  final List<Widget> _noteWidgets = [];

  @override
  void initState() {
    super.initState();
    List<Widget> _widgets =
        buildNoteWidgets(context: context, account: data.loadedAccount!);
    _noteWidgets.addAll(_widgets);
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditNoteScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: (String terms) {
      final List<Note> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (Note _note in data.loadedAccount!.notes) {
        {
          bool testNote(Note value) => _note.key == value.key;

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
      sortNotes(_found);
      List<Widget> _widgets = [];
      for (Note _note in _found) {
        _widgets.add(
          Padding(
            padding: entryPadding,
            child: buildNoteWidget(
              context: context,
              note: _note,
            ),
          ),
        );
      }
      return _widgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getEntriesScreenAppBar(context,
          title: const Center(child: Text('Notes')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: ListView(children: _noteWidgets),
    );
  }
}
