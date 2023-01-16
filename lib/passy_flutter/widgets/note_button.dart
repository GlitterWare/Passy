import 'package:flutter/material.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoteButton extends StatelessWidget {
  final NoteMeta note;
  final void Function()? onPressed;

  const NoteButton({
    Key? key,
    required this.note,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThreeWidgetButton(
      left: const Padding(
        padding: EdgeInsets.only(right: 30),
        child: Icon(Icons.note_rounded),
      ),
      right: const Icon(Icons.arrow_forward_ios_rounded),
      onPressed: onPressed,
      center: Column(
        children: [
          Align(
            child: Text(
              note.title,
            ),
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}
