import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'edit_id_card_screen.dart';
import 'common.dart';
import 'id_cards_screen.dart';
import 'main_screen.dart';

class IDCardScreen extends StatefulWidget {
  const IDCardScreen({Key? key}) : super(key: key);

  static const routeName = '/idCard';

  @override
  State<StatefulWidget> createState() => _IDCardScreen();
}

class _IDCardScreen extends State<IDCardScreen> {
  final LoadedAccount _account = data.loadedAccount!;

  @override
  Widget build(BuildContext context) {
    final IDCard _idCard = ModalRoute.of(context)!.settings.arguments as IDCard;

    void _onRemovePressed() {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              shape: PassyTheme.dialogShape,
              title: const Text('Remove password'),
              content:
                  const Text('Passwords can only be restored from a backup.'),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style:
                        TextStyle(color: PassyTheme.lightContentSecondaryColor),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(
                    'Remove',
                    style:
                        TextStyle(color: PassyTheme.lightContentSecondaryColor),
                  ),
                  onPressed: () {
                    _account.removeIDCard(_idCard.key);
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    _account.save().whenComplete(() =>
                        Navigator.pushNamed(context, IDCardsScreen.routeName));
                  },
                )
              ],
            );
          });
    }

    void _onEditPressed() {
      Navigator.pushNamed(
        context,
        EditIDCardScreen.routeName,
        arguments: _idCard,
      );
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        title: const Center(child: Text('ID Card')),
        onRemovePressed: () => _onRemovePressed(),
        onEditPressed: () => _onEditPressed(),
      ),
      body: ListView(
        children: [
          if (_idCard.nickname != '')
            PassyPadding(PassyRecord(
              title: 'Nickname',
              value: _idCard.nickname,
            )),
          if (_idCard.type != '')
            PassyPadding(PassyRecord(
              title: 'Type',
              value: _idCard.type,
            )),
          if (_idCard.idNumber != '')
            PassyPadding(PassyRecord(
              title: 'ID Number',
              value: _idCard.idNumber,
            )),
          if (_idCard.name != '')
            PassyPadding(PassyRecord(
              title: 'Name',
              value: _idCard.name,
            )),
          if (_idCard.country != '')
            PassyPadding(PassyRecord(title: 'Country', value: _idCard.country)),
          for (CustomField _customField in _idCard.customFields)
            buildCustomField(context, _customField),
          if (_idCard.additionalInfo != '')
            PassyPadding(PassyRecord(
                title: 'Additional info', value: _idCard.additionalInfo)),
        ],
      ),
    );
  }
}
