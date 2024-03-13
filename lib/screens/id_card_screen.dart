import 'package:flutter/material.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';
import 'package:passy/screens/splash_screen.dart';

import 'common.dart';
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
  bool isFavorite = false;
  IDCard? _idCard;
  List<String> _tags = [];
  List<String> _selected = [];
  bool _tagsLoaded = false;

  Future<void> _load() async {
    List<String> newTags = await _account.idCardsTags;
    if (mounted) {
      setState(() {
        _tags = newTags;
        _selected = _idCard!.tags.toList();
        for (String tag in _selected) {
          if (_tags.contains(tag)) {
            _tags.remove(tag);
          }
        }
        _tagsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_idCard == null) {
      _idCard = ModalRoute.of(context)!.settings.arguments as IDCard;
      _load();
    }
    isFavorite =
        _account.favoriteIDCards[_idCard!.key]?.status == EntryStatus.alive;

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
                    _account.removeIDCard(_idCard!.key).whenComplete(() {
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
        arguments: _idCard!,
      );
    }

    return Scaffold(
      appBar: EntryScreenAppBar(
        entryType: EntryType.idCard,
        entryKey: _idCard!.key,
        title: Center(child: Text(localizations.idCard)),
        onRemovePressed: () => _onRemovePressed(),
        onEditPressed: () => _onEditPressed(),
        isFavorite: isFavorite,
        onFavoritePressed: () async {
          if (isFavorite) {
            await _account.removeFavoriteIDCard(_idCard!.key);
            showSnackBar(
                message: localizations.removedFromFavorites,
                icon: const Icon(
                  Icons.star_outline_rounded,
                  color: PassyTheme.darkContentColor,
                ));
          } else {
            await _account.addFavoriteIDCard(_idCard!.key);
            showSnackBar(
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
          if (_tagsLoaded)
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: PassyTheme.passyPadding.top / 2,
                    bottom: PassyTheme.passyPadding.bottom / 2),
                child: EntryTagList(
                  showAddButton: true,
                  selected: _selected,
                  notSelected: _tags,
                  onAdded: (tag) async {
                    if (_idCard!.tags.contains(tag)) return;
                    Navigator.pushNamed(context, SplashScreen.routeName);
                    _idCard!.tags = _selected.toList();
                    _idCard!.tags.add(tag);
                    await _account.setIDCard(_idCard!);
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, IDCardsScreen.routeName);
                    Navigator.pushNamed(context, IDCardScreen.routeName,
                        arguments: _idCard!);
                  },
                  onRemoved: (tag) async {
                    Navigator.pushNamed(context, SplashScreen.routeName);
                    _idCard!.tags = _selected.toList();
                    _idCard!.tags.remove(tag);
                    await _account.setIDCard(_idCard!);
                    Navigator.popUntil(context,
                        (r) => r.settings.name == MainScreen.routeName);
                    Navigator.pushNamed(context, IDCardsScreen.routeName);
                    Navigator.pushNamed(context, IDCardScreen.routeName,
                        arguments: _idCard!);
                  },
                ),
              ),
            ),
          if (_idCard!.attachments.isNotEmpty)
            AttachmentsListView(files: _idCard!.attachments),
          if (_idCard!.nickname != '')
            PassyPadding(RecordButton(
              title: localizations.nickname,
              value: _idCard!.nickname,
            )),
          if (_idCard!.type != '')
            PassyPadding(RecordButton(
              title: localizations.type,
              value: _idCard!.type,
            )),
          if (_idCard!.idNumber != '')
            PassyPadding(RecordButton(
              title: localizations.idNumber,
              value: _idCard!.idNumber,
            )),
          if (_idCard!.name != '')
            PassyPadding(RecordButton(
              title: localizations.name,
              value: _idCard!.name,
            )),
          if (_idCard!.country != '')
            PassyPadding(RecordButton(
                title: localizations.country, value: _idCard!.country)),
          if (_idCard!.issDate != '')
            PassyPadding(RecordButton(
                title: localizations.dateOfIssue, value: _idCard!.issDate)),
          if (_idCard!.expDate != '')
            PassyPadding(RecordButton(
                title: localizations.expirationDate, value: _idCard!.expDate)),
          for (CustomField _customField in _idCard!.customFields)
            PassyPadding(CustomFieldButton(customField: _customField)),
          if (_idCard!.additionalInfo != '')
            PassyPadding(RecordButton(
                title: localizations.additionalInfo,
                value: _idCard!.additionalInfo)),
        ],
      ),
    );
  }
}
