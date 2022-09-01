import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';

class EditScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  final String title;
  final Function()? onSave;
  final bool isNew;

  const EditScreenAppBar({
    Key? key,
    required this.title,
    this.onSave,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: key,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: isNew
          ? Center(child: Text('Add $title'))
          : Center(child: Text('Edit $title')),
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSave,
          icon: isNew
              ? const Icon(Icons.add_rounded)
              : const Icon(Icons.check_rounded),
        ),
      ],
    );
  }
}
