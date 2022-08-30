import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/screens/edit_identity_screen.dart';
import 'package:passy/screens/identities_screen.dart';
import 'common.dart';
import 'main_screen.dart';

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
            shape: dialogShape,
            title: const Text('Remove identity'),
            content:
                const Text('Identities can only be restored from a backup.'),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style: TextStyle(color: lightContentSecondaryColor),
                ),
                onPressed: () {
                  _account.removeIdentity(_identity.key);
                  Navigator.popUntil(
                      context, (r) => r.settings.name == MainScreen.routeName);
                  _account.save().whenComplete(() =>
                      Navigator.pushNamed(context, IdentitiesScreen.routeName));
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
      appBar: getEntryScreenAppBar(
        context,
        title: const Center(child: Text('Identity')),
        onRemovePressed: _onRemovePressed,
        onEditPressed: _onEditPressed,
      ),
      body: ListView(
        children: [
          if (_identity.nickname != '')
            buildRecord(context, 'Nickname', _identity.nickname),
          buildRecord(context, 'Title', capitalize(_identity.title.name)),
          if (_identity.firstName != '')
            buildRecord(context, 'First name', _identity.firstName),
          if (_identity.middleName != '')
            buildRecord(context, 'Middle name', _identity.middleName),
          if (_identity.lastName != '')
            buildRecord(context, 'Last name', _identity.lastName),
          buildRecord(context, 'Gender', capitalize(_identity.gender.name)),
          if (_identity.email != '')
            buildRecord(context, 'Email', _identity.email),
          if (_identity.number != '')
            buildRecord(context, 'Number', _identity.number),
          if (_identity.firstAddressLine != '')
            buildRecord(
                context, 'First address line', _identity.firstAddressLine),
          if (_identity.secondAddressLine != '')
            buildRecord(
                context, 'Second address line', _identity.secondAddressLine),
          if (_identity.zipCode != '')
            buildRecord(context, 'Zip code', _identity.zipCode),
          if (_identity.city != '')
            buildRecord(context, 'City', _identity.city),
          if (_identity.country != '')
            buildRecord(context, 'Country', _identity.country),
          for (CustomField _customField in _identity.customFields)
            buildCustomField(context, _customField),
          if (_identity.additionalInfo != '')
            buildRecord(context, 'Additional info', _identity.additionalInfo),
        ],
      ),
    );
  }
}
