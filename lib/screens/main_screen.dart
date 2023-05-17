import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_screen/flutter_secure_screen.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/search_entry_data.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/id_card_screen.dart';
import 'package:passy/screens/identity_screen.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/note_screen.dart';
import 'package:passy/screens/password_screen.dart';
import 'package:passy/screens/payment_card_screen.dart';
import 'package:passy/screens/search_screen.dart';
import 'package:passy/screens/unlock_screen.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/loaded_account.dart';

import 'payment_cards_screen.dart';
import 'passwords_screen.dart';
import 'settings_screen.dart';
import 'id_cards_screen.dart';
import 'identities_screen.dart';
import 'notes_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  static bool shouldLockScreen = true;

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final LoadedAccount _account = data.loadedAccount!;
  bool _unlockScreenOn = false;

  Widget _searchBuilder(String terms) {
    final List<SearchEntryData> _found = [];
    final List<String> _terms = terms.trim().toLowerCase().split(' ');
    final List<SearchEntryData> _searchEntries = [];
    Map<String, IDCardMeta> idCardsMetadata = _account.idCardsMetadata;
    Map<String, IdentityMeta> identitiesMetadata = _account.identitiesMetadata;
    Map<String, NoteMeta> notesMetadata = _account.notesMetadata;
    Map<String, PasswordMeta> passwordsMetadata = _account.passwordsMetadata;
    Map<String, PaymentCardMeta> paymentCardsMetadata =
        _account.paymentCardsMetadata;
    if (idCardsMetadata.isEmpty &&
        identitiesMetadata.isEmpty &&
        notesMetadata.isEmpty &&
        passwordsMetadata.isEmpty &&
        paymentCardsMetadata.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                Text(
                  localizations.noEntries,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    for (IDCardMeta idCard in idCardsMetadata.values) {
      _searchEntries.add(SearchEntryData(
          name: idCard.nickname,
          description: idCard.name,
          type: EntryType.idCard,
          meta: idCard));
    }
    for (IdentityMeta _identity in identitiesMetadata.values) {
      _searchEntries.add(SearchEntryData(
          name: _identity.nickname,
          description: _identity.firstAddressLine,
          type: EntryType.identity,
          meta: _identity));
    }
    for (NoteMeta _note in notesMetadata.values) {
      _searchEntries.add(SearchEntryData(
          name: _note.title,
          description: '',
          type: EntryType.note,
          meta: _note));
    }
    for (PasswordMeta _password in passwordsMetadata.values) {
      _searchEntries.add(SearchEntryData(
          name: _password.nickname,
          description: _password.username,
          type: EntryType.password,
          meta: _password));
    }
    for (PaymentCardMeta _paymentCard in paymentCardsMetadata.values) {
      _searchEntries.add(SearchEntryData(
          name: _paymentCard.nickname,
          description: _paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: _paymentCard));
    }
    for (SearchEntryData _searchEntry in _searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            _searchEntry.meta.key == value.meta.key;

        if (_found.any(testSearchEntry)) continue;
      }
      {
        int _positiveCount = 0;
        for (String _term in _terms) {
          if (_searchEntry.name.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
          if (_searchEntry.description.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
        }
        if (_positiveCount == _terms.length) {
          _found.add(_searchEntry);
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
    return PassyEntryButtonListView(
      entries: _found,
      shouldSort: true,
      onPressed: (entry) {
        switch (entry.type) {
          case EntryType.idCard:
            Navigator.pushNamed(context, IDCardScreen.routeName,
                arguments: _account.getIDCard(entry.meta.key));
            return;
          case EntryType.identity:
            Navigator.pushNamed(context, IdentityScreen.routeName,
                arguments: _account.getIdentity(entry.meta.key));
            return;
          case EntryType.note:
            Navigator.pushNamed(context, NoteScreen.routeName,
                arguments: _account.getNote(entry.meta.key));
            return;
          case EntryType.password:
            Navigator.pushNamed(context, PasswordScreen.routeName,
                arguments: _account.getPassword(entry.meta.key));
            return;
          case EntryType.paymentCard:
            Navigator.pushNamed(context, PaymentCardScreen.routeName,
                arguments: _account.getPaymentCard(entry.meta.key));
            return;
        }
      },
      popupMenuItemBuilder: passyEntryPopupMenuItemBuilder,
    );
  }

  Widget _favoritesSearchBuilder(String terms) {
    if (!_account.hasFavorites) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                const Spacer(flex: 7),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: '${localizations.noFavorites}.',
                        children: [
                          TextSpan(text: '\n\n${localizations.noFavorites1}'),
                          const WidgetSpan(
                              child: Icon(Icons.star_outline_rounded)),
                          TextSpan(text: ' ${localizations.noFavorites2}.'),
                        ])),
                const Spacer(flex: 7),
              ],
            ),
          ),
        ],
      );
    }
    final List<SearchEntryData> _found = [];
    final List<String> _terms = terms.trim().toLowerCase().split(' ');
    final List<SearchEntryData> _searchEntries = [];
    Map<String, IDCardMeta> idCardsMetadata = _account.idCardsMetadata;
    Map<String, IdentityMeta> identitiesMetadata = _account.identitiesMetadata;
    Map<String, NoteMeta> notesMetadata = _account.notesMetadata;
    Map<String, PasswordMeta> passwordsMetadata = _account.passwordsMetadata;
    Map<String, PaymentCardMeta> paymentCardsMetadata =
        _account.paymentCardsMetadata;
    _account.reloadFavoritesSync();
    for (EntryEvent event in _account.favoriteIDCards.values) {
      if (event.status == EntryStatus.removed) continue;
      IDCardMeta? idCard = idCardsMetadata[event.key];
      if (idCard == null) continue;
      _searchEntries.add(SearchEntryData(
          name: idCard.nickname,
          description: idCard.name,
          type: EntryType.idCard,
          meta: idCard));
    }
    for (EntryEvent event in _account.favoriteIdentities.values) {
      if (event.status == EntryStatus.removed) continue;
      IdentityMeta? _identity = identitiesMetadata[event.key];
      if (_identity == null) continue;
      _searchEntries.add(SearchEntryData(
          name: _identity.nickname,
          description: _identity.firstAddressLine,
          type: EntryType.identity,
          meta: _identity));
    }
    for (EntryEvent event in _account.favoriteNotes.values) {
      if (event.status == EntryStatus.removed) continue;
      NoteMeta? _note = notesMetadata[event.key];
      if (_note == null) continue;
      _searchEntries.add(SearchEntryData(
          name: _note.title,
          description: '',
          type: EntryType.note,
          meta: _note));
    }
    for (EntryEvent event in _account.favoritePasswords.values) {
      if (event.status == EntryStatus.removed) continue;
      PasswordMeta? _password = passwordsMetadata[event.key];
      if (_password == null) continue;
      _searchEntries.add(SearchEntryData(
          name: _password.nickname,
          description: _password.username,
          type: EntryType.password,
          meta: _password));
    }
    for (EntryEvent event in _account.favoritePaymentCards.values) {
      if (event.status == EntryStatus.removed) continue;
      PaymentCardMeta? _paymentCard = paymentCardsMetadata[event.key];
      if (_paymentCard == null) continue;
      _searchEntries.add(SearchEntryData(
          name: _paymentCard.nickname,
          description: _paymentCard.cardholderName,
          type: EntryType.paymentCard,
          meta: _paymentCard));
    }
    for (SearchEntryData _searchEntry in _searchEntries) {
      {
        bool testSearchEntry(SearchEntryData value) =>
            _searchEntry.meta.key == value.meta.key;

        if (_found.any(testSearchEntry)) continue;
      }
      {
        int _positiveCount = 0;
        for (String _term in _terms) {
          if (_searchEntry.name.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
          if (_searchEntry.description.toLowerCase().contains(_term)) {
            _positiveCount++;
            continue;
          }
        }
        if (_positiveCount == _terms.length) {
          _found.add(_searchEntry);
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
    return PassyEntryButtonListView(
      entries: _found,
      shouldSort: true,
      onPressed: (entry) {
        switch (entry.type) {
          case EntryType.idCard:
            Navigator.pushNamed(context, IDCardScreen.routeName,
                arguments: _account.getIDCard(entry.meta.key));
            return;
          case EntryType.identity:
            Navigator.pushNamed(context, IdentityScreen.routeName,
                arguments: _account.getIdentity(entry.meta.key));
            return;
          case EntryType.note:
            Navigator.pushNamed(context, NoteScreen.routeName,
                arguments: _account.getNote(entry.meta.key));
            return;
          case EntryType.password:
            Navigator.pushNamed(context, PasswordScreen.routeName,
                arguments: _account.getPassword(entry.meta.key));
            return;
          case EntryType.paymentCard:
            Navigator.pushNamed(context, PaymentCardScreen.routeName,
                arguments: _account.getPaymentCard(entry.meta.key));
            return;
        }
      },
      popupMenuItemBuilder: passyEntryPopupMenuItemBuilder,
    );
  }

  void _logOut() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: PassyTheme.dialogShape,
          title: Text(localizations.logOut),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  localizations.stay,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  data.unloadAccount();
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                },
                child: Text(
                  localizations.logOut,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                )),
          ],
          content: Text(localizations.areYouSureYouWantToLogOutQuestion),
        );
      },
    );
  }

  Future<bool> _onWillPop() {
    _logOut();
    return Future.value(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!MainScreen.shouldLockScreen) return;
    if (_unlockScreenOn) return;
    if (data.loadedAccount?.autoScreenLock == false) return;
    _unlockScreenOn = true;
    Navigator.pushNamed(context, UnlockScreen.routeName)
        .then((value) => _unlockScreenOn = false);
  }

  @override
  Future<bool> didPushRoute(String route) {
    if (route == UnlockScreen.routeName) _unlockScreenOn = true;
    return Future.value(true);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      FlutterSecureScreen.singleton
          .setAndroidScreenSecure(_account.protectScreen);
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screenButtons = [
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.star_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.favorites),
        onPressed: () async {
          await _account.reloadFavorites();
          if (mounted) {
            Navigator.pushNamed(context, SearchScreen.routeName,
                arguments: SearchScreenArgs(
                  title: localizations.favorites,
                  builder: _favoritesSearchBuilder,
                ));
          }
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(CupertinoIcons.globe),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.searchAllEntries),
        onPressed: () => Navigator.pushNamed(context, SearchScreen.routeName,
            arguments: SearchScreenArgs(
              title: localizations.allEntries,
              builder: _searchBuilder,
            )),
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.qr_code_scanner),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.synchronize),
        onPressed: () {
          if (!_account.isRSAKeypairLoaded) {
            showSnackBar(
              context,
              message: localizations.settingUpSynchronization,
              icon: const Icon(CupertinoIcons.clock_solid,
                  color: PassyTheme.darkContentColor),
            );
            return;
          }
          showSynchronizationDialog(context);
        },
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.password_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.passwords),
        onPressed: () =>
            Navigator.pushNamed(context, PasswordsScreen.routeName),
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.payment_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.paymentCards),
        onPressed: () =>
            Navigator.pushNamed(context, PaymentCardsScreen.routeName),
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.note_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.notes),
        onPressed: () => Navigator.pushNamed(context, NotesScreen.routeName),
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.perm_identity_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.idCards),
        onPressed: () => Navigator.pushNamed(context, IDCardsScreen.routeName),
      )),
      PassyPadding(ThreeWidgetButton(
        left: const Padding(
          padding: EdgeInsets.only(right: 30),
          child: Icon(Icons.people_outline_rounded),
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        center: Text(localizations.identities),
        onPressed: () =>
            Navigator.pushNamed(context, IdentitiesScreen.routeName),
      )),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Passy'),
          leading: IconButton(
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            padding: PassyTheme.appBarButtonPadding,
            tooltip: localizations.logOut,
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: const Icon(Icons.exit_to_app_rounded),
            ),
            onPressed: _logOut,
          ),
          actions: [
            IconButton(
              padding: PassyTheme.appBarButtonPadding,
              tooltip: localizations.search,
              onPressed: () =>
                  Navigator.pushNamed(context, SearchScreen.routeName,
                      arguments: SearchScreenArgs(
                        title: localizations.allEntries,
                        builder: _searchBuilder,
                      )),
              icon: const Icon(Icons.search_rounded),
              splashRadius: PassyTheme.appBarButtonSplashRadius,
            ),
            IconButton(
              splashRadius: PassyTheme.appBarButtonSplashRadius,
              padding: PassyTheme.appBarButtonPadding,
              tooltip: localizations.synchronize,
              onPressed: () {
                if (!_account.isRSAKeypairLoaded) {
                  showSnackBar(
                    context,
                    message: localizations.settingUpSynchronization,
                    icon: const Icon(CupertinoIcons.clock_solid,
                        color: PassyTheme.darkContentColor),
                  );
                  return;
                }
                showSynchronizationDialog(context);
              },
              icon: const Icon(Icons.sync_rounded),
            ),
            IconButton(
              padding: PassyTheme.appBarButtonPadding,
              tooltip: localizations.settings,
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsScreen.routeName),
              icon: const Icon(Icons.settings),
              splashRadius: PassyTheme.appBarButtonSplashRadius,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (ctx, constr) {
            if (constr.maxWidth >= 1100) {
              return Row(children: [
                Expanded(
                    child: ListView(
                  children: [
                    _screenButtons[0],
                    _screenButtons[1],
                    _screenButtons[2],
                  ],
                )),
                Expanded(
                    child: ListView(
                  children: [
                    _screenButtons[3],
                    _screenButtons[4],
                    _screenButtons[5],
                  ],
                )),
                Expanded(
                    child: ListView(
                  children: [
                    _screenButtons[6],
                    _screenButtons[7],
                  ],
                ))
              ]);
            }
            if (constr.maxWidth >= 700) {
              return Row(children: [
                Expanded(
                  child: ListView(children: [
                    _screenButtons[0],
                    _screenButtons[1],
                    _screenButtons[2],
                    _screenButtons[3],
                  ]),
                ),
                Expanded(
                    child: ListView(
                  children: [
                    _screenButtons[4],
                    _screenButtons[5],
                    _screenButtons[6],
                    _screenButtons[7],
                  ],
                )),
              ]);
            }
            return ListView(children: _screenButtons);
          },
        ),
      ),
    );
  }
}
