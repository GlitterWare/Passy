import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/screens/edit_identity_screen.dart';
import 'package:passy/screens/identities_screen.dart';
import 'package:passy/widgets/record_widget.dart';
import '../widgets/widgets.dart';
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
            PassyPadding(PassyRecord(
              title: 'Nickname',
              value: _identity.nickname,
            )),
          PassyPadding(PassyRecord(
              title: 'Title', value: capitalize(_identity.title.name))),
          if (_identity.firstName != '')
            PassyPadding(PassyRecord(
              title: 'First name',
              value: _identity.firstName,
            )),
          if (_identity.middleName != '')
            PassyPadding(PassyRecord(
              title: 'Middle name',
              value: _identity.middleName,
            )),
          if (_identity.lastName != '')
            PassyPadding(PassyRecord(
              title: 'Last name',
              value: _identity.lastName,
            )),
          PassyPadding(PassyRecord(
            title: 'Gender',
            value: capitalize(_identity.gender.name),
          )),
          if (_identity.email != '')
            PassyPadding(PassyRecord(
              title: 'Email',
              value: _identity.email,
            )),
          if (_identity.number != '')
            PassyPadding(PassyRecord(
              title: 'Number',
              value: _identity.number,
            )),
          if (_identity.firstAddressLine != '')
            PassyPadding(PassyRecord(
                title: 'First address line',
                value: _identity.firstAddressLine)),
          if (_identity.secondAddressLine != '')
            PassyPadding(PassyRecord(
                title: 'Second address line',
                value: _identity.secondAddressLine)),
          if (_identity.zipCode != '')
            PassyPadding(PassyRecord(
              title: 'Zip code',
              value: _identity.zipCode,
            )),
          if (_identity.city != '')
            PassyPadding(PassyRecord(
              title: 'City',
              value: _identity.city,
            )),
          if (_identity.country != '')
            PassyPadding(PassyRecord(
              title: 'Country',
              value: _identity.country,
            )),
          for (CustomField _customField in _identity.customFields)
            buildCustomField(context, _customField),
          if (_identity.additionalInfo != '')
            PassyPadding(PassyRecord(
                title: 'Additional info', value: _identity.additionalInfo)),
        ],
      ),
    );
  }
}
