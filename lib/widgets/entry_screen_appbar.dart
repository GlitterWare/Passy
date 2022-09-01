import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class EntryScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final Widget title;
  final void Function()? onRemovePressed;
  final void Function()? onEditPressed;

  const EntryScreenAppBar({
    Key? key,
    required this.title,
    this.onRemovePressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onRemovePressed,
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.edit_rounded),
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
