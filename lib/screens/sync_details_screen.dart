import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/synchronization.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';
import 'id_card_screen.dart';
import 'identity_screen.dart';
import 'note_screen.dart';
import 'payment_card_screen.dart';
import 'password_screen.dart';

class SyncDetailsScreenArgs {
  final SynchronizationReport report;
  final Map<String, PasswordMeta> passwordsMetadata;
  final Map<String, NoteMeta> notesMetadata;
  final Map<String, PaymentCardMeta> paymentCardsMetadata;
  final Map<String, IDCardMeta> idCardsMetadata;
  final Map<String, IdentityMeta> identitiesMetadata;

  SyncDetailsScreenArgs({
    required this.report,
    required this.passwordsMetadata,
    required this.notesMetadata,
    required this.paymentCardsMetadata,
    required this.idCardsMetadata,
    required this.identitiesMetadata,
  });
}

class SyncDetailsScreen extends StatefulWidget {
  static const routeName = '/main/syncDetails';

  const SyncDetailsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SyncDetailsScreen();
}

class _SyncDetailsScreen extends State<SyncDetailsScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    final SyncDetailsScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as SyncDetailsScreenArgs;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.details),
          centerTitle: true,
          leading: IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(tabs: [
            Tab(
              icon: const Icon(Icons.password),
              text: localizations.passwords,
            ),
            Tab(
              icon: const Icon(Icons.payment_rounded),
              text: localizations.paymentCards,
            ),
            Tab(
              icon: const Icon(Icons.note_rounded),
              text: localizations.notes,
            ),
            Tab(
              icon: const Icon(Icons.perm_identity_rounded),
              text: localizations.idCards,
            ),
            Tab(
              icon: const Icon(Icons.people_outline_rounded),
              text: localizations.identities,
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            args.passwordsMetadata.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const Spacer(flex: 7),
                            Text(
                              localizations.noChanges,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 7),
                          ],
                        ),
                      ),
                    ],
                  )
                : PasswordButtonListView(
                    passwords: args.passwordsMetadata.values.toList(),
                    onPressed: (password) {
                      try {
                        Navigator.pushNamed(context, PasswordScreen.routeName,
                            arguments: _account.getPassword(password.key)!);
                      } catch (e) {
                        showSnackBar(
                          message: localizations.entryDoesNotExist,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                      }
                    },
                    shouldSort: true,
                    syncStates: args.report.changedPasswords,
                  ),
            args.paymentCardsMetadata.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const Spacer(flex: 7),
                            Text(
                              localizations.noChanges,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 7),
                          ],
                        ),
                      ),
                    ],
                  )
                : PaymentCardButtonMiniListView(
                    paymentCards: args.paymentCardsMetadata.values.toList(),
                    onPressed: (paymentCard) {
                      try {
                        Navigator.pushNamed(
                            context, PaymentCardScreen.routeName,
                            arguments:
                                _account.getPaymentCard(paymentCard.key)!);
                      } catch (e) {
                        showSnackBar(
                          message: localizations.entryDoesNotExist,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                      }
                    },
                    shouldSort: true,
                    syncStates: args.report.changedPaymentCards,
                  ),
            args.notesMetadata.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const Spacer(flex: 7),
                            Text(
                              localizations.noChanges,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 7),
                          ],
                        ),
                      ),
                    ],
                  )
                : NoteButtonListView(
                    notes: args.notesMetadata.values.toList(),
                    onPressed: (note) {
                      try {
                        Navigator.pushNamed(context, NoteScreen.routeName,
                            arguments: _account.getNote(note.key)!);
                      } catch (e) {
                        showSnackBar(
                          message: localizations.entryDoesNotExist,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                      }
                    },
                    shouldSort: true,
                    syncStates: args.report.changedNotes,
                  ),
            args.idCardsMetadata.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const Spacer(flex: 7),
                            Text(
                              localizations.noChanges,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 7),
                          ],
                        ),
                      ),
                    ],
                  )
                : IDCardButtonListView(
                    idCards: args.idCardsMetadata.values.toList(),
                    onPressed: (idCard) {
                      try {
                        Navigator.pushNamed(context, IDCardScreen.routeName,
                            arguments: _account.getIDCard(idCard.key)!);
                      } catch (e) {
                        showSnackBar(
                          message: localizations.entryDoesNotExist,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                      }
                    },
                    shouldSort: true,
                    syncStates: args.report.changedIDCards,
                  ),
            args.identitiesMetadata.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const Spacer(flex: 7),
                            Text(
                              localizations.noChanges,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 7),
                          ],
                        ),
                      ),
                    ],
                  )
                : IdentityButtonListView(
                    identities: args.identitiesMetadata.values.toList(),
                    onPressed: (identity) {
                      try {
                        Navigator.pushNamed(context, IdentityScreen.routeName,
                            arguments: _account.getIdentity(identity.key)!);
                      } catch (e) {
                        showSnackBar(
                          message: localizations.entryDoesNotExist,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: PassyTheme.darkContentColor),
                        );
                      }
                    },
                    shouldSort: true,
                    syncStates: args.report.changedIdentities,
                  ),
          ],
        ),
      ),
    );
  }
}
