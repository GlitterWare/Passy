import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  static const routeName = '/addNote';

  @override
  State<StatefulWidget> createState() => _AddNoteScreen();
}

class _AddNoteScreen extends State<AddNoteScreen> {
  late Widget _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Text('Add Note'),
      ),
    );
  }
}
