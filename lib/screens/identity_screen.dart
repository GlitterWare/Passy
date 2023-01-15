import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/splash_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final Identity _identity =
        ModalRoute.of(context)!.settings.arguments as Identity;

    void _onRemovePressed() {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: PassyTheme.dialogShape,
            title: const Text('Remove identity'),
            content:
                const Text('Identities can only be restored from a backup.'),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Remove',
                  style:
                      TextStyle(color: PassyTheme.lightContentSecondaryColor),
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
        title: const Center(child: Text('Identity')),
        onRemovePressed: _onRemovePressed,
        onEditPressed: _onEditPressed,
      ),
      body: ListView(
        children: [
          if (_identity.nickname != '')
            PassyPadding(RecordButton(
              title: 'Nickname',
              value: _identity.nickname,
            )),
          PassyPadding(RecordButton(
              title: 'Title', value: capitalize(_identity.title.name))),
          if (_identity.firstName != '')
            PassyPadding(RecordButton(
              title: 'First name',
              value: _identity.firstName,
            )),
          if (_identity.middleName != '')
            PassyPadding(RecordButton(
              title: 'Middle name',
              value: _identity.middleName,
            )),
          if (_identity.lastName != '')
            PassyPadding(RecordButton(
              title: 'Last name',
              value: _identity.lastName,
            )),
          PassyPadding(RecordButton(
            title: 'Gender',
            value: capitalize(_identity.gender.name),
          )),
          if (_identity.email != '')
            PassyPadding(RecordButton(
              title: 'Email',
              value: _identity.email,
            )),
          if (_identity.number != '')
            PassyPadding(RecordButton(
              title: 'Number',
              value: _identity.number,
            )),
          if (_identity.firstAddressLine != '')
            PassyPadding(RecordButton(
                title: 'First address line',
                value: _identity.firstAddressLine)),
          if (_identity.secondAddressLine != '')
            PassyPadding(RecordButton(
                title: 'Second address line',
                value: _identity.secondAddressLine)),
          if (_identity.zipCode != '')
            PassyPadding(RecordButton(
              title: 'Zip code',
              value: _identity.zipCode,
            )),
          if (_identity.city != '')
            PassyPadding(RecordButton(
              title: 'City',
              value: _identity.city,
            )),
          if (_identity.country != '')
            PassyPadding(RecordButton(
              title: 'Country',
              value: _identity.country,
            )),
          for (CustomField _customField in _identity.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (_identity.additionalInfo != '')
            PassyPadding(RecordButton(
                title: 'Additional info', value: _identity.additionalInfo)),
        ],
      ),
    );
  }
}
