import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

AppBar getEntriesScreenAppBar(
  BuildContext context, {
  Key? key,
  required Widget title,
  required void Function()? onSearchPressed,
  required void Function()? onAddPressed,
}) =>
    AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: title,
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSearchPressed,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onAddPressed,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );

class EntriesScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
  final Widget _title;
  final void Function()? _onSearchPressed;
  final void Function()? _onAddPressed;

  const EntriesScreenAppBar({
    Key? key,
    required Widget title,
    void Function()? onSearchPressed,
    void Function()? onAddPressed,
  })  : _title = title,
        _onSearchPressed = onSearchPressed,
        _onAddPressed = onAddPressed,
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
          onPressed: _onSearchPressed,
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: _onAddPressed,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
