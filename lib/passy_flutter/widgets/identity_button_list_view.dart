import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/sync_entry_state.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class IdentityButtonListView extends StatelessWidget {
  final List<IdentityMeta> identities;
  final bool shouldSort;
  final void Function(IdentityMeta identity)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, IdentityMeta identityMeta)? popupMenuItemBuilder;
  final List<Widget>? topWidgets;
  final Map<String, SyncEntryState> syncStates;

  const IdentityButtonListView({
    Key? key,
    required this.identities,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
    this.topWidgets,
    Map<String, SyncEntryState>? syncStates,
  })  : syncStates = syncStates ?? const {},
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortIdentities(identities);
    List<Widget> _entriesWidgets = [];
    for (IdentityMeta identity in identities) {
      SyncEntryState? state = syncStates[identity.key];
      Widget? stateIcon;
      switch (state) {
        case null:
          break;
        case SyncEntryState.added:
          stateIcon = const Icon(Icons.add, color: Colors.green, size: 28);
          break;
        case SyncEntryState.removed:
          stateIcon = const Icon(Icons.remove, color: Colors.red, size: 28);
          break;
        case SyncEntryState.modified:
          stateIcon = const Icon(Icons.edit, color: Colors.yellow, size: 28);
          break;
      }
      _entriesWidgets.add(PassyPadding(IdentityButton(
        leftWidget: stateIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  PassyTheme.passyPadding.left,
                  PassyTheme.passyPadding.top,
                  PassyTheme.passyPadding.right * 2,
                  PassyTheme.passyPadding.bottom,
                ),
                child: stateIcon,
              ),
        identity: identity,
        onPressed: onPressed == null ? null : () => onPressed!(identity),
        popupMenuItemBuilder: popupMenuItemBuilder == null
            ? null
            : (context) => popupMenuItemBuilder!(context, identity),
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
