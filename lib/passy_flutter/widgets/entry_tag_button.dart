import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EntryTagButton extends StatelessWidget {
  final String tag;
  final Color? color;
  final bool isSelected;
  final void Function()? onPressed;
  final void Function()? onSecondary;

  const EntryTagButton(
    this.tag, {
    super.key,
    this.color,
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
            backgroundColor: WidgetStatePropertyAll(
                color ?? PassyTheme.of(context).highlightContentColor),
          ),
          icon: Icon(isSelected ? Icons.close_rounded : Icons.add_rounded,
              color: Theme.of(context).colorScheme.onPrimary),
          label: Padding(
            padding: EdgeInsets.only(
                top: PassyTheme.of(context).passyPadding.top / 1.5,
                bottom: PassyTheme.of(context).passyPadding.bottom / 1.5,
                right: PassyTheme.of(context).passyPadding.right),
            child: Text(
              tag,
              style: TextStyle(
                  color: PassyTheme.of(context).highlightContentTextColor,
                  height: 0.01),
            ),
          ),
        ));
  }
}
