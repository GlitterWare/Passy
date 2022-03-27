abstract class DatedEntry<T> {
  final DateTime creationDate;
  int compareTo(T other);

  DatedEntry(this.creationDate);

  Map<String, dynamic> toJson();
}
