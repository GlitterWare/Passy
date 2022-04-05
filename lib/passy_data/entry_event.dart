import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/json_convertable.dart';
import 'package:passy/passy_data/password.dart';

enum EntryStatus { alive, removed }

const _$EntryStatusEnumMap = {
  EntryStatus.alive: 'alive',
  EntryStatus.removed: 'removed',
};

class EntryEvent implements JsonConvertable {
  final EntryType entryType;
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.entryType,
    required this.status,
    required this.lastModified,
  });

  factory EntryEvent.fromJson(Map<String, dynamic> json) => EntryEvent(
      entryType: entryTypeFromJson(json['entryType']),
      status: $enumDecodeNullable(_$EntryStatusEnumMap, json['status']) ??
          EntryStatus.alive,
      lastModified: DateTime.parse(json['lastModified']));

  @override
  Map<String, dynamic> toJson() => {
        'entryType': entryTypeToJson(entryType),
        'status': _$EntryStatusEnumMap[status],
        'lastModified': lastModified.toIso8601String(),
      };
}
