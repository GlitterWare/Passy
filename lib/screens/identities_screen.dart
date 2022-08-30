import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/screens/edit_identity_screen.dart';
import 'package:passy/widgets/passy_identity.dart';
import 'package:passy/widgets/widgets.dart';

import 'common.dart';
import 'main_screen.dart';
import 'search_screen.dart';

class IdentitiesScreen extends StatefulWidget {
  const IdentitiesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/identities';

  @override
  State<StatefulWidget> createState() => _IdentitiesScreen();
}

class _IdentitiesScreen extends State<IdentitiesScreen> {
  final List<Widget> _identityWidgets = [];

  @override
  void initState() {
    super.initState();
    List<Widget> _widgets = buildIdentityWidgets(
        context: context, identities: data.loadedAccount!.identities.toList());
    _identityWidgets.addAll(_widgets);
  }

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIdentityScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: (String terms) {
      final List<Identity> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (Identity _identity in data.loadedAccount!.identities) {
        {
          bool testIdentity(Identity value) => _identity.key == value.key;

          if (_found.any(testIdentity)) continue;
        }
        {
          int _positiveCount = 0;
          for (String _term in _terms) {
            if (_identity.firstAddressLine.toLowerCase().contains(_term)) {
              _positiveCount++;
              continue;
            }
            if (_identity.nickname.toLowerCase().contains(_term)) {
              _positiveCount++;
              continue;
            }
          }
          if (_positiveCount == _terms.length) {
            _found.add(_identity);
          }
        }
      }
      sortIdentities(_found);
      List<Widget> _widgets = [];
      for (Identity _identity in _found) {
        _widgets.add(
          PassyPadding(PassyIdentity(identity: _identity)),
        );
      }
      return _widgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getEntriesScreenAppBar(context,
          title: const Center(child: Text('Identities')),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: ListView(children: _identityWidgets),
    );
  }
}
