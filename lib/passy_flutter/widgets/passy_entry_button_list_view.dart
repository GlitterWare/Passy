import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PassyEntryButtonListView extends StatelessWidget {
  final List<SearchEntryData> entries;
  final bool shouldSort;
  final void Function(SearchEntryData entry)? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(
      BuildContext context, SearchEntryData entryMeta)? popupMenuItemBuilder;

  const PassyEntryButtonListView({
    Key? key,
    required this.entries,
    this.shouldSort = false,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortEntries(entries);
    return ListView(
      children: [
        for (SearchEntryData entry in entries)
          PassyPadding(entry.toWidget(
            onPressed: onPressed == null ? null : () => onPressed!(entry),
            popupMenuItemBuilder: popupMenuItemBuilder == null
                ? null
                : (context) => popupMenuItemBuilder!(context, entry),
          )),
      ],
    );
  }
}
