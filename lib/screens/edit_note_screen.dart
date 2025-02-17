import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'common.dart';
import 'note_screen.dart';
import 'notes_screen.dart';
import 'splash_screen.dart';
import 'main_screen.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({Key? key}) : super(key: key);

  static const routeName = '${NoteScreen.routeName}/edit';

  @override
  State<StatefulWidget> createState() => _EditNoteScreen();
}

class _EditNoteScreen extends State<EditNoteScreen> {
  bool _isLoaded = false;
  bool _isNew = true;

  String? _key;
  String _title = '';
  String _note = '';
  bool _isMarkdown = false;
  List<String> _attachments = [];

  void _onSave() async {
    final LoadedAccount _account = data.loadedAccount!;
    Note _noteArgs = Note(
      key: _key,
      title: _title,
      note: _note,
      isMarkdown: _isMarkdown,
      attachments: _attachments,
    );
    Navigator.pushNamed(context, SplashScreen.routeName);
    await _account.setNote(_noteArgs);
    Navigator.popUntil(context, (r) => r.settings.name == MainScreen.routeName);
    Navigator.pushNamed(context, NotesScreen.routeName);
    Navigator.pushNamed(context, NoteScreen.routeName, arguments: _noteArgs);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;
      _isNew = _args == null;
      if (!_isNew) {
        Note _noteArgs = _args as Note;
        _key = _noteArgs.key;
        _title = _noteArgs.title;
        _note = _noteArgs.note;
        _isMarkdown = _noteArgs.isMarkdown;
        _attachments = List.from(_noteArgs.attachments);
      }
      _isLoaded = true;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: _onSave,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: EditScreenAppBar(
        title: localizations.note.toLowerCase(),
        isNew: _isNew,
        onSave: _onSave,
      ),
      body: ListView(children: [
        AttachmentsEditor(
          files: _attachments,
          onFileAdded: (key) => setState(() => _attachments.add(key)),
          onFileRemoved: (key) => setState(() => _attachments.remove(key)),
        ),
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.enableMarkdown),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              'assets/images/markdown-svgrepo-com.svg',
              width: 26,
              colorFilter: ColorFilter.mode(
                  PassyTheme.of(context).contentTextColor, BlendMode.srcIn),
            ),
          ),
          right: Switch(
            activeColor: Colors.greenAccent,
            value: _isMarkdown,
            onChanged: (value) => setState(() => _isMarkdown = value),
          ),
          onPressed: () => setState(() => _isMarkdown = !_isMarkdown),
        )),
        PassyPadding(TextFormField(
          initialValue: _title,
          decoration: InputDecoration(labelText: localizations.title),
          onChanged: (value) => setState(() => _title = value.trim()),
        )),
        PassyPadding(TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          initialValue: _note,
          decoration: InputDecoration(
            labelText: localizations.note,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).highlightContentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).contentSecondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(
                  color: PassyTheme.of(context).highlightContentColor),
            ),
          ),
          onChanged: (value) => setState(() => _note = value),
        )),
        if (_isMarkdown)
          PassyPadding(Text(
            localizations.markdownPreview,
            style: TextStyle(
                color: PassyTheme.of(context).highlightContentSecondaryColor),
          )),
        if (_isMarkdown)
          Padding(
              padding: EdgeInsets.fromLTRB(
                  20,
                  PassyTheme.of(context).passyPadding.top,
                  PassyTheme.of(context).passyPadding.right,
                  PassyTheme.of(context).passyPadding.bottom),
              child: PassyMarkdownBody(data: _note)),
        const SizedBox(height: floatingActionButtonPadding),
      ]),
    );
  }
}
