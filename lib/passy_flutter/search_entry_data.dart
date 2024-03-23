import 'package:flutter/material.dart';
import 'package:passy/passy_data/entry_meta.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

String _nameFromEntry(EntryType type, EntryMeta entry) {
  switch (type) {
    case EntryType.idCard:
      return (entry as IDCardMeta).nickname;
    case EntryType.identity:
      return (entry as IdentityMeta).nickname;
    case EntryType.note:
      return (entry as NoteMeta).title;
    case EntryType.password:
      return (entry as PasswordMeta).nickname;
    case EntryType.paymentCard:
      return (entry as PaymentCardMeta).nickname;
    default:
      return '';
  }
}

String _descriptionFromEntry(EntryType type, EntryMeta entry) {
  switch (type) {
    case EntryType.idCard:
      return (entry as IDCardMeta).name;
    case EntryType.identity:
      return (entry as IdentityMeta).firstAddressLine;
    case EntryType.note:
      return '';
    case EntryType.password:
      return (entry as PasswordMeta).username;
    case EntryType.paymentCard:
      return (entry as PaymentCardMeta).cardholderName;
    default:
      return '';
  }
}

List<String> _tagsFromEntry(EntryType type, EntryMeta entry) {
  switch (type) {
    case EntryType.idCard:
      return (entry as IDCardMeta).tags;
    case EntryType.identity:
      return (entry as IdentityMeta).tags;
    case EntryType.note:
      return (entry as NoteMeta).tags;
    case EntryType.password:
      return (entry as PasswordMeta).tags;
    case EntryType.paymentCard:
      return (entry as PaymentCardMeta).tags;
    default:
      return [];
  }
}

class SearchEntryData {
  final String name;
  final String description;
  final EntryType type;
  final EntryMeta meta;
  final List<String> tags;

  SearchEntryData({
    required this.name,
    required this.description,
    required this.type,
    required this.meta,
    required this.tags,
  });

  SearchEntryData.fromEntry({
    required this.type,
    required this.meta,
  })  : name = _nameFromEntry(type, meta),
        description = _descriptionFromEntry(type, meta),
        tags = _tagsFromEntry(type, meta);

  static List<SearchEntryData> fromEntries({
    List<IDCardMeta>? idCards,
    List<IdentityMeta>? identities,
    List<NoteMeta>? notes,
    List<PasswordMeta>? passwords,
    List<PaymentCardMeta>? paymentCards,
  }) {
    List<SearchEntryData> _result = [];
    idCards?.forEach((idCard) => _result.add(SearchEntryData(
        name: idCard.nickname,
        description: idCard.name,
        type: EntryType.idCard,
        meta: idCard,
        tags: idCard.tags)));
    identities?.forEach((identity) => _result.add(SearchEntryData(
        name: identity.nickname,
        description: identity.firstAddressLine,
        type: EntryType.identity,
        meta: identity,
        tags: identity.tags)));
    notes?.forEach((note) => _result.add(SearchEntryData(
        name: note.title,
        description: '',
        type: EntryType.note,
        meta: note,
        tags: note.tags)));
    passwords?.forEach((password) => _result.add(SearchEntryData(
        name: password.nickname,
        description: password.username,
        type: EntryType.password,
        meta: password,
        tags: password.tags)));
    paymentCards?.forEach((paymentCard) => _result.add(SearchEntryData(
        name: paymentCard.nickname,
        description: paymentCard.cardholderName,
        type: EntryType.paymentCard,
        meta: paymentCard,
        tags: paymentCard.tags)));
    return _result;
  }

  Widget toWidget(
      {void Function()? onPressed,
      List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
          popupMenuItemBuilder}) {
    switch (type) {
      case EntryType.idCard:
        return IDCardButton(
          idCard: meta as IDCardMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.identity:
        return IdentityButton(
          identity: meta as IdentityMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.note:
        return NoteButton(
          note: meta as NoteMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.password:
        return PasswordButton(
          password: meta as PasswordMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
      case EntryType.paymentCard:
        return PaymentCardButtonMini(
          paymentCard: meta as PaymentCardMeta,
          onPressed: onPressed,
          popupMenuItemBuilder: popupMenuItemBuilder,
        );
    }
  }
}
