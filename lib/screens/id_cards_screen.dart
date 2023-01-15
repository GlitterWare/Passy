import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

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

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIDCardScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: (String terms) {
      final List<IDCard> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (IDCard _idCard in _account.idCards.values) {
        {
          bool testIDCard(IDCard value) => _idCard.key == value.key;

          if (_found.any(testIDCard)) continue;
        }
        {
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
      return IDCardButtonListView(
        idCards: _found,
        shouldSort: true,
        onPressed: (idCard) => Navigator.pushNamed(
          context,
          IDCardScreen.routeName,
          arguments: idCard,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EntriesScreenAppBar(
          title: const Center(child: Text('ID cards')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _account.idCards.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      const Text(
                        'No ID cards',
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
              idCards: _account.idCards.values.toList(),
              shouldSort: true,
              onPressed: (idCard) => Navigator.pushNamed(
                  context, IDCardScreen.routeName,
                  arguments: idCard),
            ),
    );
  }
}
