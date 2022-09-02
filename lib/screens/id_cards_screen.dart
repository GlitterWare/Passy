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
      for (IDCard _idCard in data.loadedAccount!.idCards) {
        {
          bool testIDCard(IDCard value) => _idCard.key == value.key;

          if (_found.any(testIDCard)) continue;
        }
        {
          int _positiveCount = 0;
          for (String _term in _terms) {
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
      PassySort.sortIDCards(_found);
      List<Widget> _widgets = [];
      for (IDCard _idCard in _found) {
        _widgets.add(
          PassyPadding(IDCardButton(idCard: _idCard)),
        );
      }
      return _widgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EntriesScreenAppBar(
          title: const Center(child: Text('ID Cards')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: IDCardButtonListView(
        idCards: _account.idCards.toList(),
        shouldSort: true,
        onPressed: (idCard) => Navigator.pushNamed(
            context, IDCardScreen.routeName,
            arguments: idCard),
      ),
    );
  }
}
