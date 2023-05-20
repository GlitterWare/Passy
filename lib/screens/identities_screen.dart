import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/identity_screen.dart';

import 'main_screen.dart';
import 'search_screen.dart';
import 'edit_identity_screen.dart';

class IdentitiesScreen extends StatefulWidget {
  const IdentitiesScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/identities';

  @override
  State<StatefulWidget> createState() => _IdentitiesScreen();
}

class _IdentitiesScreen extends State<IdentitiesScreen> {
  final _account = data.loadedAccount!;

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditIdentityScreen.routeName);

  void _onSearchPressed() {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(builder: (String terms) {
      final List<IdentityMeta> _found = [];
      final List<String> _terms = terms.trim().toLowerCase().split(' ');
      for (IdentityMeta _identity in _account.identitiesMetadata.values) {
        {
          bool testIdentity(IdentityMeta value) => _identity.key == value.key;

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
      if (_found.isEmpty) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
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
      return IdentityButtonListView(
        identities: _found,
        shouldSort: true,
        onPressed: (identity) => Navigator.pushNamed(
          context,
          IdentityScreen.routeName,
          arguments: _account.getIdentity(identity.key),
        ),
        popupMenuItemBuilder: identityPopupMenuBuilder,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<IdentityMeta> _identities =
        _account.identitiesMetadata.values.toList();
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.identity,
          title: Center(child: Text(localizations.identities)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _identities.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noIdentities,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditIdentityScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : IdentityButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addIdentity,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditIdentityScreen.routeName),
                  ),
                ),
              ],
              identities: _identities,
              shouldSort: true,
              onPressed: (identity) => Navigator.pushNamed(
                context,
                IdentityScreen.routeName,
                arguments: _account.getIdentity(identity.key),
              ),
              popupMenuItemBuilder: identityPopupMenuBuilder,
            ),
    );
  }
}
