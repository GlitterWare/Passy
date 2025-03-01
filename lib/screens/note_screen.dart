import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'common.dart';
import 'log_screen.dart';
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
  Note? _note;
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;

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
                  style: TextStyle(
                      color: PassyTheme.of(context)
                          .highlightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(color: Colors.red),
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

  Future<void> _load() async {
    List<String> newTags = await _account.notesTags;
    newTags.sort();
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = _note!.tags.toList();
        _selected.sort();
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
        _tagsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      _note = ModalRoute.of(context)!.settings.arguments as Note;
      _load();
    }
    _account.reloadFavoritesSync();
    isFavorite =
        _account.favoriteNotes[_note!.key]?.status == EntryStatus.alive;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () => _onEditPressed(_note!),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: EntryScreenAppBar(
        entryType: EntryType.note,
        entryKey: _note!.key,
        title: Center(child: Text(localizations.note)),
        onRemovePressed: () => _onRemovePressed(_note!),
        onEditPressed: () => _onEditPressed(_note!),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoriteNote(_note!.key);
            showSnackBar(
              message: localizations.removedFromFavorites,
              icon: const Icon(Icons.star_outline_rounded),
            );
          } else {
            await _account.addFavoriteNote(_note!.key);
            showSnackBar(
              message: localizations.addedToFavorites,
              icon: const Icon(Icons.star_rounded),
            );
          }
          setState(() {});
        },
      ),
      body: ListView(children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.of(context).passyPadding.top / 2,
                bottom: PassyTheme.of(context).passyPadding.bottom / 2),
            child: !_tagsLoaded
                ? const CircularProgressIndicator()
                : EntryTagList(
                    showAddButton: true,
                    selected: _selected,
                    notSelected: _tags,
                    onSecondary: (tag) async {
                      String? newTag = await showDialog(
                        context: context,
                        builder: (ctx) => RenameTagDialog(tag: tag),
                      );
                      if (newTag == null) return;
                      if (newTag == tag) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      try {
                        await _account.renameTag(tag: tag, newTag: newTag);
                      } catch (e, s) {
                        Navigator.pop(context);
                        showSnackBar(
                          message: localizations.somethingWentWrong,
                          icon: const Icon(Icons.error_outline_rounded),
                          action: SnackBarAction(
                            label: localizations.details,
                            onPressed: () => Navigator.pushNamed(
                                context, LogScreen.routeName,
                                arguments: e.toString() + '\n' + s.toString()),
                          ),
                        );
                        return;
                      }
                      _note!.tags = _selected.toList();
                      if (_note!.tags.contains(tag)) {
                        _note!.tags.remove(tag);
                        _note!.tags.add(newTag);
                      }
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName);
                      Navigator.pushNamed(context, NoteScreen.routeName,
                          arguments: _note!);
                    },
                    onAdded: (tag) async {
                      if (_note!.tags.contains(tag)) return;
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      _note!.tags = _selected.toList();
                      _note!.tags.add(tag);
                      await _account.setNote(_note!);
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName);
                      Navigator.pushNamed(context, NoteScreen.routeName,
                          arguments: _note!);
                    },
                    onRemoved: (tag) async {
                      Navigator.pushNamed(context, SplashScreen.routeName);
                      _note!.tags = _selected.toList();
                      _note!.tags.remove(tag);
                      await _account.setNote(_note!);
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, NotesScreen.routeName);
                      Navigator.pushNamed(context, NoteScreen.routeName,
                          arguments: _note!);
                    },
                  ),
          ),
        ),
        if (_note!.title != '')
          PassyPadding(
              RecordButton(title: localizations.title, value: _note!.title)),
        if (_note!.attachments.isNotEmpty)
          AttachmentsListView(files: _note!.attachments),
        if (_note!.note != '')
          if (!_note!.isMarkdown)
            PassyPadding(RecordButton(
              title: localizations.note,
              value: _note!.note,
              valueAlign: TextAlign.left,
            )),
        if (_note!.isMarkdown)
          PassyPadding(Text(
            localizations.note,
            style: TextStyle(
                color: PassyTheme.of(context).highlightContentSecondaryColor),
          )),
        if (_note!.isMarkdown)
          Padding(
            padding: EdgeInsets.fromLTRB(
                20,
                PassyTheme.of(context).passyPadding.top,
                PassyTheme.of(context).passyPadding.right,
                PassyTheme.of(context).passyPadding.bottom),
            child: PassyMarkdownBody(data: _note!.note),
          ),
        const SizedBox(height: floatingActionButtonPadding),
      ]),
    );
  }
}
