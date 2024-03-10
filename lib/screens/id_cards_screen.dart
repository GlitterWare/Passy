import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'edit_id_card_screen.dart';
import 'id_card_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';

class IDCardsScreen extends StatefulWidget {
  const IDCardsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/idCards';

  @override
  State<StatefulWidget> createState() => _IDCardsScreen();
}

class _IDCardsScreen extends State<IDCardsScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  List<String> _tags = [];

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIDCardScreen.routeName);

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            notSelectedTags: _tags.toList()..remove(tag),
            selectedTags: tag == null ? [] : [tag],
            builder:
                (String terms, List<String> tags, void Function() rebuild) {
              final List<IDCardMeta> _found = [];
              final List<String> _terms = terms.trim().toLowerCase().split(' ');
              for (IDCardMeta _idCard in _account.idCardsMetadata.values) {
                {
                  bool testIDCard(IDCardMeta value) => _idCard.key == value.key;

                  if (_found.any(testIDCard)) continue;
                }
                {
                  bool _tagMismatch = false;
                  for (String tag in tags) {
                    if (_idCard.tags.contains(tag)) continue;
                    _tagMismatch = true;
                  }
                  if (_tagMismatch) continue;
                  int _positiveCount = 0;
                  for (String _term in _terms) {
                    if (_idCard.nickname.toLowerCase().contains(_term)) {
                      _positiveCount++;
                      continue;
                    }
                    if (_idCard.name.toLowerCase().contains(_term)) {
                      _positiveCount++;
                      continue;
                    }
                  }
                  if (_positiveCount == _terms.length) {
                    _found.add(_idCard);
                  }
                }
              }
              if (_found.isEmpty) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          const Spacer(flex: 7),
                          Text(
                            localizations.noSearchResults,
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(flex: 7),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return IDCardButtonListView(
                idCards: _found,
                shouldSort: true,
                onPressed: (idCard) => Navigator.pushNamed(
                  context,
                  IDCardScreen.routeName,
                  arguments: _account.getIDCard(idCard.key),
                ),
                popupMenuItemBuilder: idCardPopupMenuBuilder,
              );
            }));
  }

  Future<void> _load() async {
    List<String> newTags = await _account.idCardsTags;
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    List<IDCardMeta> _idCards = _account.idCardsMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.idCard,
          title: Center(child: Text(localizations.idCards)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _idCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noIDCards,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditIDCardScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IDCardButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addIDCard,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditIDCardScreen.routeName),
                  ),
                ),
                if (_tags.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: PassyTheme.passyPadding.top / 2,
                          bottom: PassyTheme.passyPadding.bottom / 2),
                      child: EntryTagList(
                        notSelected: _tags,
                        onAdded: (tag) => setState(() {
                          _onSearchPressed(tag: tag);
                        }),
                      ),
                    ),
                  ),
              ],
              idCards: _idCards,
              shouldSort: true,
              onPressed: (idCard) => Navigator.pushNamed(
                  context, IDCardScreen.routeName,
                  arguments: _account.getIDCard(idCard.key)),
              popupMenuItemBuilder: idCardPopupMenuBuilder,
            ),
    );
  }
}
