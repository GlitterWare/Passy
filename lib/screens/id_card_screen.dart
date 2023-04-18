import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/splash_screen.dart';

import 'edit_id_card_screen.dart';
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
              title: Text(localizations.removeIDCard),
              content:
                  Text('${localizations.idCardsCanOnlyBeRestoredFromABackup}.'),
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
                    _account.removeIDCard(_idCard.key).whenComplete(() {
                      Navigator.popUntil(context,
                          (r) => r.settings.name == MainScreen.routeName);
                      Navigator.pushNamed(context, IDCardsScreen.routeName);
                    });
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
        title: Center(child: Text(localizations.idCard)),
        onRemovePressed: () => _onRemovePressed(),
        onEditPressed: () => _onEditPressed(),
      ),
      body: ListView(
        children: [
          if (_idCard.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: _idCard.nickname,
            )),
          if (_idCard.type != '')
            PassyPadding(RecordButton(
              title: localizations.type,
              value: _idCard.type,
            )),
          if (_idCard.idNumber != '')
            PassyPadding(RecordButton(
              title: localizations.idNumber,
              value: _idCard.idNumber,
            )),
          if (_idCard.name != '')
            PassyPadding(RecordButton(
              title: localizations.name,
              value: _idCard.name,
            )),
          if (_idCard.country != '')
            PassyPadding(RecordButton(
                title: localizations.country, value: _idCard.country)),
          for (CustomField _customField in _idCard.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (_idCard.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: _idCard.additionalInfo)),
        ],
      ),
    );
  }
}
