import 'package:json_annotation/json_annotation.dart';

enum EntryStatus { alive, removed }

const _$EntryStatusEnumMap = {
  EntryStatus.alive: 'alive',
  EntryStatus.removed: 'removed',
};

class EntryEvent {
  EntryStatus status;
  DateTime lastModified;

  EntryEvent({
    required this.status,
    required this.lastModified,
  });

  factory EntryEvent.fromJson(Map<String, dynamic> json) => EntryEvent(
      status: $enumDecodeNullable(_$EntryStatusEnumMap, json['status']) ??
          EntryStatus.alive,
      lastModified: DateTime.parse(json['lastModified']));

  Map<String, dynamic> toJson() => {
        'status': _$EntryStatusEnumMap[status],
        'lastModified': lastModified.toIso8601String(),
      };
}
