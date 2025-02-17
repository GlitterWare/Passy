import 'package:flutter/material.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/sync_entry_state.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PasswordButtonListView extends StatelessWidget {
  final List<PasswordMeta> passwords;
  final bool shouldSort;
  final void Function(PasswordMeta password)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, PasswordMeta passwordMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;
  final Map<String, SyncEntryState> syncStates;

  const PasswordButtonListView({
    Key? key,
    required this.passwords,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
    Map<String, SyncEntryState>? syncStates,
  })  : syncStates = syncStates ?? const {},
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPasswords(passwords);
    List<Widget> _entriesWidgets = [];
    for (PasswordMeta password in passwords) {
      SyncEntryState? state = syncStates[password.key];
      Widget? stateIcon;
      switch (state) {
        case null:
          break;
        case SyncEntryState.added:
          stateIcon = const Icon(Icons.add, color: Colors.green, size: 28);
          break;
        case SyncEntryState.removed:
          stateIcon =
              const Icon(Icons.delete_rounded, color: Colors.red, size: 28);
          break;
        case SyncEntryState.modified:
          stateIcon = const Icon(Icons.edit, color: Colors.yellow, size: 28);
          break;
      }
      _entriesWidgets.add(PassyPadding(PasswordButton(
        leftWidget: stateIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  PassyTheme.of(context).passyPadding.left,
                  PassyTheme.of(context).passyPadding.top,
                  PassyTheme.of(context).passyPadding.right * 2,
                  PassyTheme.of(context).passyPadding.bottom,
                ),
                child: stateIcon,
              ),
        password: password,
        onPressed: onPressed == null ? null : () => onPressed!(password),
        popupMenuItemBuilder: popupMenuItemBuilder == null
            ? null
            : (ctx) => popupMenuItemBuilder!(ctx, password),
      )));
    }
    return ListView(
      children: [
        if (topWidgets != null) ...topWidgets!,
        ..._entriesWidgets,
      ],
    );
  }
}
