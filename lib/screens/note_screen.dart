import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';

import 'common.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  static const routeName = '/main/note';

  @override
  State<StatefulWidget> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  @override
  Widget build(BuildContext context) {
    final Note? _note = ModalRoute.of(context)!.settings.arguments as Note?;
    return Scaffold(
      appBar: AppBar(
        leading: getBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Note')),
      ),
    );
  }
}
