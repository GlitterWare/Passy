import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'common.dart';
import 'main_screen.dart';
import 'edit_note_screen.dart';
import 'notes_screen.dart';
import 'splash_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const routeName = '/note';

  @override
  State<StatefulWidget> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  bool isFavorite = false;

  void _onRemovePressed(Note note) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removeNote),
            content:
                Text('${localizations.notesCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  _account.removeNote(note.key).whenComplete(() {
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, NotesScreen.routeName);
                  });
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
    isFavorite = _account.favoriteNotes[_note.key]?.status == EntryStatus.alive;

    return Scaffold(
      appBar: EntryScreenAppBar(
        title: Center(child: Text(localizations.note)),
        onRemovePressed: () => _onRemovePressed(_note),
        onEditPressed: () => _onEditPressed(_note),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoriteNote(_note.key);
            showSnackBar(context,
                message: localizations.removedFromFavorites,
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          } else {
            await _account.addFavoriteNote(_note.key);
            showSnackBar(context,
                message: localizations.addedToFavorites,
                icon: const Icon(
                  Icons.star_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          }
          setState(() {});
        },
      ),
      body: ListView(children: [
        if (_note.title != '')
          PassyPadding(
              RecordButton(title: localizations.title, value: _note.title)),
        if (_note.note != '')
          PassyPadding(RecordButton(
            title: localizations.note,
            value: _note.note,
            valueAlign: TextAlign.left,
          )),
      ]),
    );
  }
}
