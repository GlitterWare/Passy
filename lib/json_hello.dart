import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_hello.g.dart';

@JsonSerializable()
class Inside {
  int b = 0;
  @JsonKey(name: 'c', required: true)
  int _c = 0;
  int get c => _c;
  void setC(int c) => _c = c;
  void printC() => print(c);

  Inside();
  factory Inside.fromJson(Map<String, dynamic> json) => _$InsideFromJson(json);
  Map<String, dynamic> toJson() => _$InsideToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Test {
  int a = 1;
  Inside inside = Inside();

  Test();
  factory Test.fromJson(Map<String, dynamic> json) => _$TestFromJson(json);
  Map<String, dynamic> toJson() => _$TestToJson(this);
}
