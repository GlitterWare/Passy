import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  static const routeName = '/addNote';

  @override
  State<StatefulWidget> createState() => _AddNoteScreen();
}

class _AddNoteScreen extends State<AddNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
