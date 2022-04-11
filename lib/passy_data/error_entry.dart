import 'package:passy/passy_data/passy_entry.dart';

class ErrorEntry extends PassyEntry<ErrorEntry> {
  String details;

  ErrorEntry({this.details = ''}) : super('0');

  @override
  int compareTo(ErrorEntry other) => 0;

  @override
  Map<String, dynamic> toJson() => {};
}
