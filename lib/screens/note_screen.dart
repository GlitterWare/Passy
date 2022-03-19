import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy/note.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const routeName = '/note';

  @override
  State<StatefulWidget> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  Widget? _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    final Note? _note = ModalRoute.of(context)!.settings.arguments as Note?;
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Text('Note'),
      ),
    );
  }
}
