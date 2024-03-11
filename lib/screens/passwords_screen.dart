import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_search.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';

import 'edit_password_screen.dart';
import 'main_screen.dart';
import 'password_screen.dart';
import 'search_screen.dart';

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({Key? key}) : super(key: key);

  static const routeName = '${MainScreen.routeName}/passwords';

  @override
  State<StatefulWidget> createState() => _PasswordsScreen();
}

class _PasswordsScreen extends State<PasswordsScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  List<String> _tags = [];

  void _onAddPressed() =>
      Navigator.pushNamed(context, EditPasswordScreen.routeName);

  Widget _buildPasswords(
    String terms,
    List<String> tags,
    void Function() rebuild,
  ) {
    List<PasswordMeta> _found = PassySearch.searchPasswords(
        passwords: _account.passwordsMetadata.values, terms: terms, tags: tags);
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
    return PasswordButtonListView(
      passwords: _found,
      onPressed: (password) => Navigator.pushNamed(
          context, PasswordScreen.routeName,
          arguments: _account.getPassword(password.key)!),
      shouldSort: true,
      popupMenuItemBuilder: passwordPopupMenuBuilder,
    );
  }

  void _onSearchPressed({String? tag}) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: SearchScreenArgs(
            builder: _buildPasswords,
            notSelectedTags: _tags.toList()..remove(tag),
            selectedTags: tag == null ? [] : [tag]));
  }

  Future<void> _load() async {
    List<String> newTags;
    try {
      newTags = await _account.passwordTags;
    } catch (_) {
      return;
    }
    if (listEquals(newTags, _tags)) {
      return;
    }
    if (mounted) {
      setState(() {
        _tags = newTags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    List<PasswordMeta> _passwords = [];
    try {
      _passwords = _account.passwordsMetadata.values.toList();
    } catch (_) {}
    return Scaffold(
      appBar: EntriesScreenAppBar(
          entryType: EntryType.password,
          title: Center(child: Text(localizations.passwords)),
          onSearchPressed: _onSearchPressed,
          onAddPressed: _onAddPressed),
      body: _passwords.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(flex: 7),
                      Text(
                        localizations.noPasswords,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          child: const Icon(Icons.add_rounded),
                          onPressed: () => Navigator.pushNamed(
                              context, EditPasswordScreen.routeName)),
                      const Spacer(flex: 7),
                    ],
                  ),
                ),
              ],
            )
          : PasswordButtonListView(
              topWidgets: [
                PassyPadding(
                  ThreeWidgetButton(
                    left: const Icon(Icons.add_rounded),
                    center: Text(
                      localizations.addPassword,
                      textAlign: TextAlign.center,
                    ),
                    right: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: () => Navigator.pushNamed(
                        context, EditPasswordScreen.routeName),
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
              passwords: _passwords.toList(),
              onPressed: (password) => Navigator.pushNamed(
                  context, PasswordScreen.routeName,
                  arguments: _account.getPassword(password.key)!),
              shouldSort: true,
              popupMenuItemBuilder: passwordPopupMenuBuilder,
            ),
    );
  }
}
