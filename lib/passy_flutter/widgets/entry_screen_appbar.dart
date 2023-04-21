import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';

class EntryScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final EdgeInsetsGeometry buttonPadding;
  final double buttonSplashRadius;
  final Widget title;
  final void Function()? onRemovePressed;
  final void Function()? onEditPressed;
  final bool isFavorite;
  final void Function()? onFavoritePressed;

  const EntryScreenAppBar({
    Key? key,
    this.buttonPadding = PassyTheme.appBarButtonPadding,
    this.buttonSplashRadius = PassyTheme.appBarButtonSplashRadius,
    required this.title,
    this.onRemovePressed,
    this.onEditPressed,
    this.isFavorite = false,
    this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        padding: buttonPadding,
        splashRadius: buttonSplashRadius,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: localizations.remove,
          onPressed: onRemovePressed,
        ),
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          tooltip: isFavorite
              ? localizations.removeFromFavorites
              : localizations.addToFavorites,
          icon: isFavorite
              ? const Icon(Icons.star_rounded)
              : const Icon(Icons.star_outline_rounded),
          onPressed: onFavoritePressed,
        ),
        IconButton(
          padding: buttonPadding,
          splashRadius: buttonSplashRadius,
          tooltip: localizations.edit,
          icon: const Icon(Icons.edit_rounded),
          onPressed: onEditPressed,
        ),
      ],
    );
  }
}
