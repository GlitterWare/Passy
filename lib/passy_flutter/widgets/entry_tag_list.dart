import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EntryTagList extends StatefulWidget {
  final List<String> selected;
  final List<String> notSelected;
  final void Function(String tag) onAdded;
  final void Function(String tag) onRemoved;
  final void Function(String tag) onSecondary;
  final void Function() onAddPressed;
  final bool showAddButton;

  const EntryTagList({
    super.key,
    this.selected = const [],
    this.notSelected = const [],
    void Function(String tag)? onAdded,
    void Function(String tag)? onRemoved,
    void Function(String tag)? onSecondary,
    void Function()? onAddPressed,
    this.showAddButton = false,
  })  : onAdded = onAdded ?? _onChanged,
        onRemoved = onRemoved ?? _onChanged,
        onSecondary = onSecondary ?? _voidString,
        onAddPressed = onAddPressed ?? _void;

  static void _onChanged(tag) {}
  static void _void() {}
  static void _voidString(String foobar) {}

  @override
  State<StatefulWidget> createState() => _EntryTagList();
}

class _EntryTagList extends State<EntryTagList> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _key = GlobalKey();

  bool showScrollbar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        showScrollbar = (_key.currentContext?.size?.width ?? 0) ==
            MediaQuery.of(context).size.width;
      });
    });

    List<Widget> notSelectedButtons = [];
    List<Widget> selectedButtons = [];

    for (String tag in widget.selected) {
      selectedButtons.add(
        Padding(
          padding: EdgeInsets.only(
              left: PassyTheme.passyPadding.left / 2,
              right: PassyTheme.passyPadding.right / 2,
              bottom: showScrollbar ? 14 : 0),
          child: EntryTagButton(
            tag,
            isSelected: true,
            onPressed: () {
              widget.onRemoved(tag);
            },
            onSecondary: () {
              widget.onSecondary(tag);
            },
          ),
        ),
      );
    }

    for (String tag in widget.notSelected) {
      notSelectedButtons.add(
        Padding(
          padding: EdgeInsets.only(
              left: PassyTheme.passyPadding.left / 2,
              right: PassyTheme.passyPadding.right / 2,
              bottom: showScrollbar ? 14 : 0),
          child: EntryTagButton(
            tag,
            onPressed: () {
              widget.onAdded(tag);
            },
            onSecondary: () {
              widget.onSecondary(tag);
            },
          ),
        ),
      );
    }

    Widget scrollView = CustomScrollView(
      controller: _scrollController,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverList.list(
          children: [
            Row(
              children: [
                if (selectedButtons.isEmpty && notSelectedButtons.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        left: PassyTheme.passyPadding.left / 2,
                        right: PassyTheme.passyPadding.right / 2,
                        bottom: showScrollbar ? 14 : 0),
                    child: Text(localizations.noTags),
                  ),
                if (selectedButtons.isEmpty && notSelectedButtons.isEmpty)
                  const SizedBox(width: 10),
                if (widget.showAddButton)
                  Padding(
                    padding: EdgeInsets.only(bottom: showScrollbar ? 14 : 0),
                    child: FloatingActionButton(
                      heroTag: null,
                      child: const Icon(Icons.add),
                      onPressed: () {
                        widget.onAddPressed();
                        showDialog(
                          context: context,
                          builder: (context) => const EntryTagCreationDialog(),
                        ).then((value) {
                          if (value is! String) return;
                          widget.onAdded(value);
                        });
                      },
                    ),
                  ),
                ...selectedButtons,
                if (selectedButtons.isNotEmpty && notSelectedButtons.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        left: PassyTheme.passyPadding.left / 2,
                        right: PassyTheme.passyPadding.right / 2,
                        bottom: showScrollbar ? 14 : 0),
                    child: const SizedBox(
                      height: 36,
                      width: 2,
                      child: DecoratedBox(
                        decoration:
                            BoxDecoration(color: PassyTheme.lightContentColor),
                      ),
                    ),
                  ),
                ...notSelectedButtons,
              ],
            ),
          ],
        ),
      ],
    );

    return SizedBox(
      key: _key,
      height: showScrollbar ? 50 : 36,
      child: PrimaryScrollController(
        controller: _scrollController,
        child: showScrollbar
            ? Scrollbar(
                thumbVisibility: true,
                child: scrollView,
              )
            : scrollView,
      ),
    );
  }
}
