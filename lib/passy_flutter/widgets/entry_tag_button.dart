import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EntryTagButton extends StatelessWidget {
  final String tag;
  final Color color;
  final bool isSelected;
  final void Function()? onPressed;

  const EntryTagButton(
    this.tag, {
    super.key,
    this.color = PassyTheme.lightContentColor,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
      ),
      icon: Icon(isSelected ? Icons.close_rounded: Icons.add_rounded),
      label: Padding(
        padding: EdgeInsets.only(
            top: PassyTheme.passyPadding.top,
            bottom: PassyTheme.passyPadding.bottom,
            right: PassyTheme.passyPadding.right),
        child: Text(
          tag,
          style: const TextStyle(color: PassyTheme.darkContentColor),
        ),
      ),
    );
  }
}
