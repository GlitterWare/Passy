import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/splash_screen.dart';

import 'common.dart';
import 'main_screen.dart';
import 'edit_identity_screen.dart';
import 'identities_screen.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/identity';

  @override
  State<StatefulWidget> createState() => _IdentityScreen();
}

class _IdentityScreen extends State<IdentityScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final Identity _identity =
        ModalRoute.of(context)!.settings.arguments as Identity;
    isFavorite =
        _account.favoriteIdentities[_identity.key]?.status == EntryStatus.alive;

    void _onRemovePressed() {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(localizations.removeIdentity),
            content: Text(
                '${localizations.identitiesCanOnlyBeRestoredFromABackup}.'),
            actions: [
              TextButton(
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  localizations.remove,
                  style: const TextStyle(
                      color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SplashScreen.routeName);
                  _account.removeIdentity(_identity.key).whenComplete(() {
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, IdentitiesScreen.routeName);
                  });
                },
              )
            ],
          );
        },
      );
    }

    void _onEditPressed() {
      Navigator.pushNamed(
        context,
        EditIdentityScreen.routeName,
        arguments: _identity,
      );
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.identity,
        entryKey: _identity.key,
        title: Center(child: Text(localizations.identity)),
        onRemovePressed: _onRemovePressed,
        onEditPressed: _onEditPressed,
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoriteIdentity(_identity.key);
            showSnackBar(context,
                message: localizations.removedFromFavorites,
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          } else {
            await _account.addFavoriteIdentity(_identity.key);
            showSnackBar(context,
                message: localizations.addedToFavorites,
                icon: const Icon(
                  Icons.star_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          }
          setState(() {});
        },
      ),
      body: ListView(
        children: [
          if (_identity.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: _identity.nickname,
            )),
          PassyPadding(RecordButton(
              title: localizations.title,
              value: capitalize(_identity.title.name))),
          if (_identity.firstName != '')
            PassyPadding(RecordButton(
              title: localizations.firstName,
              value: _identity.firstName,
            )),
          if (_identity.middleName != '')
            PassyPadding(RecordButton(
              title: localizations.middleName,
              value: _identity.middleName,
            )),
          if (_identity.lastName != '')
            PassyPadding(RecordButton(
              title: localizations.lastName,
              value: _identity.lastName,
            )),
          PassyPadding(RecordButton(
            title: localizations.gender,
            value: genderToReadableName(_identity.gender),
          )),
          if (_identity.email != '')
            PassyPadding(RecordButton(
              title: localizations.email,
              value: _identity.email,
            )),
          if (_identity.number != '')
            PassyPadding(RecordButton(
              title: localizations.phoneNumber,
              value: _identity.number,
            )),
          if (_identity.firstAddressLine != '')
            PassyPadding(RecordButton(
                title: localizations.firstAddresssLine,
                value: _identity.firstAddressLine)),
          if (_identity.secondAddressLine != '')
            PassyPadding(RecordButton(
                title: localizations.secondAddressLine,
                value: _identity.secondAddressLine)),
          if (_identity.zipCode != '')
            PassyPadding(RecordButton(
              title: localizations.zipCode,
              value: _identity.zipCode,
            )),
          if (_identity.city != '')
            PassyPadding(RecordButton(
              title: localizations.city,
              value: _identity.city,
            )),
          if (_identity.country != '')
            PassyPadding(RecordButton(
              title: localizations.country,
              value: _identity.country,
            )),
          for (CustomField _customField in _identity.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (_identity.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: _identity.additionalInfo)),
        ],
      ),
    );
  }
}
