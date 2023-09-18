import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      }
      _isLoaded = true;
    }

    return Scaffold(
      appBar: EditScreenAppBar(
        title: localizations.note.toLowerCase(),
        isNew: _isNew,
        onSave: () async {
          final LoadedAccount _account = data.loadedAccount!;
          Note _noteArgs = Note(
              key: _key, title: _title, note: _note, isMarkdown: _isMarkdown);
          Navigator.pushNamed(context, SplashScreen.routeName);
          await _account.setNote(_noteArgs);
          Navigator.popUntil(
              context, (r) => r.settings.name == MainScreen.routeName);
          Navigator.pushNamed(context, NotesScreen.routeName);
          Navigator.pushNamed(context, NoteScreen.routeName,
              arguments: _noteArgs);
        },
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: Text(localizations.enableMarkdown),
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: SvgPicture.asset(
              'assets/images/markdown-svgrepo-com.svg',
              width: 26,
              colorFilter: const ColorFilter.mode(
                  PassyTheme.lightContentColor, BlendMode.srcIn),
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
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide:
                  const BorderSide(color: PassyTheme.darkContentSecondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: PassyTheme.lightContentColor),
            ),
          ),
          onChanged: (value) => setState(() => _note = value),
        )),
        if (_isMarkdown)
          PassyPadding(Text(
            localizations.markdownPreview,
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          )),
        if (_isMarkdown)
          Padding(
              padding: EdgeInsets.fromLTRB(
                  20,
                  PassyTheme.passyPadding.top,
                  PassyTheme.passyPadding.right,
                  PassyTheme.passyPadding.bottom),
              child: MarkdownBody(
                data: _note,
                selectable: true,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  <md.InlineSyntax>[
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ],
                ),
                onTapLink: (text, url, title) {
                  if (url == null) return;
                  openUrl(url);
                },
              )),
      ]),
    );
  }
}
