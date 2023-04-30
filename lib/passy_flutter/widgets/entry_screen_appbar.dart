import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

class EntryScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final EntryType entryType;
  final String entryKey;
  final EdgeInsetsGeometry buttonPadding;
  final double buttonSplashRadius;
  final Widget title;
  final void Function()? onRemovePressed;
  final void Function()? onEditPressed;
  final bool isFavorite;
  final void Function()? onFavoritePressed;

  const EntryScreenAppBar({
    Key? key,
    required this.entryType,
    required this.entryKey,
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
          icon: const Icon(Icons.qr_code),
          tooltip: localizations.shareEntry,
          onPressed: () {
            if (!data.loadedAccount!.isRSAKeypairLoaded) {
              showSnackBar(
                context,
                message: localizations.settingUpSynchronization,
                icon: const Icon(CupertinoIcons.clock_solid,
                    color: PassyTheme.darkContentColor),
              );
              return;
            }
            SynchronizationWrapper(context: context).host(data.loadedAccount!,
                title: Text(
                  localizations.shareEntry,
                  textAlign: TextAlign.center,
                ),
                sharedEntryKeys: {
                  entryType: [entryKey],
                });
          },
        ),
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
