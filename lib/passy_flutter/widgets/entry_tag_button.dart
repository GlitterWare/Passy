import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EntryTagButton extends StatelessWidget {
  final String tag;
  final Color color;
  final bool isSelected;
  final void Function()? onPressed;
  final void Function()? onSecondary;

  const EntryTagButton(
    this.tag, {
    super.key,
    this.color = PassyTheme.lightContentColor,
    this.isSelected = false,
    this.onPressed,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onSecondaryTap: onSecondary,
        child: TextButton.icon(
          onLongPress: onSecondary,
          onPressed: onPressed ?? () {},
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(color),
          ),
          icon: Icon(isSelected ? Icons.close_rounded : Icons.add_rounded,
              color: PassyTheme.theme.colorScheme.onPrimary),
          label: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.passyPadding.top / 1.5,
                bottom: PassyTheme.passyPadding.bottom / 1.5,
                right: PassyTheme.passyPadding.right),
            child: Text(
              tag,
              style: const TextStyle(
                  color: PassyTheme.darkContentColor, height: 0.01),
            ),
          ),
        ));
  }
}
