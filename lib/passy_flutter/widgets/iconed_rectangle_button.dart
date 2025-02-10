import 'package:flutter/material.dart';
import 'package:passy_website/passy_flutter/passy_flutter.dart';

class IconedRectangleButton extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final void Function()? onPressed;
  final Color? backgroundColor;

  const IconedRectangleButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
        ),
        backgroundColor: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          children: [
            Center(child: PassyPadding(icon)),
            Center(child: PassyPadding(label)),
          ],
        ),
      ),
    );
  }
}
