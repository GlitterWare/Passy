import 'package:json_annotation/json_annotation.dart';
import 'package:passy/passy_data/json_convertable.dart';

enum EntryStatus { alive, removed }

const _$EntryStatusEnumMap = {
  EntryStatus.alive: 'alive',
  EntryStatus.removed: 'removed',
};

class EntryEvent implements JsonConvertable {
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

  @override
  Map<String, dynamic> toJson() => {
        'status': _$EntryStatusEnumMap[status],
        'lastModified': lastModified.toIso8601String(),
      };
}
