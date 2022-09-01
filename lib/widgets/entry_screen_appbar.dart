import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class EntryScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
  final Widget _title;
  final void Function()? _onRemovePressed;
  final void Function()? _onEditPressed;

  const EntryScreenAppBar({
    Key? key,
    required Widget title,
    required void Function()? onRemovePressed,
    required void Function()? onEditPressed,
  })  : _title = title,
        _onRemovePressed = onRemovePressed,
        _onEditPressed = onEditPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: _title,
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: _onRemovePressed,
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          icon: const Icon(Icons.edit_rounded),
          onPressed: _onEditPressed,
        ),
      ],
    );
  }
}
