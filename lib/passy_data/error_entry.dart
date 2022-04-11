import 'package:passy/passy_data/dated_entry.dart';

class ErrorEntry extends DatedEntry<ErrorEntry> {
  String details;

  ErrorEntry({this.details = ''}) : super('0');

  @override
  int compareTo(ErrorEntry other) => 0;

  @override
  Map<String, dynamic> toJson() => {};
}
