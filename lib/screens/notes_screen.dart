import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
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
  List<String> _tags = [];

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditNoteScreen.routeName);

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(
      context,
      SearchScreen.routeName,
      arguments: SearchScreenArgs(
        notSelectedTags: _tags.toList()..remove(tag),
        selectedTags: tag == null ? [] : [tag],
        builder: (String terms, List<String> tags, void Function() rebuild) {
          final List<NoteMeta> _found = [];
          final List<String> _terms = terms.trim().toLowerCase().split(' ');
          for (NoteMeta _note in _account.notesMetadata.values) {
            {
              bool testNote(NoteMeta value) => _note.key == value.key;

              if (_found.any(testNote)) continue;
            }
            {
              bool _tagMismatch = false;
              for (String tag in tags) {
                if (_note.tags.contains(tag)) continue;
                _tagMismatch = true;
              }
              if (_tagMismatch) continue;
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
          if (_found.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noSearchResults,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            );
          }
          return NoteButtonListView(
            notes: _found,
            shouldSort: true,
            onPressed: (note) => Navigator.pushNamed(
                context, NoteScreen.routeName,
                arguments: _account.getNote(note.key)),
            popupMenuItemBuilder: notePopupMenuBuilder,
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    List<String> newTags = await _account.notesTags;
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    List<NoteMeta> _notes = _account.notesMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.note,
          title: Center(child: Text(localizations.notes)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _notes.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noNotes,
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
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addNote,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () =>
                        Navigator.pushNamed(context, EditNoteScreen.routeName),
                  ),
                ),
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
                    ),
                  ),
              ],
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
