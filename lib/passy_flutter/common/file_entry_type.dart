import 'package:passy/passy_data/passy_file_type.dart';

enum FileEntryType {
  unknown,
  file,
  plainText,
  markdown,
  photo,
  folder,
}

PassyFileType? passyFileTypeFromFileEntryType(FileEntryType type) {
  switch (type) {
    case FileEntryType.unknown:
      return PassyFileType.unknown;
    case FileEntryType.file:
      return PassyFileType.unknown;
    case FileEntryType.plainText:
      return PassyFileType.text;
    case FileEntryType.markdown:
      return PassyFileType.markdown;
    case FileEntryType.photo:
      return PassyFileType.photo;
    case FileEntryType.folder:
      return null;
  }
}

FileEntryType fileEntryTypeFromPassyFileType(PassyFileType type) {
  switch (type) {
    case PassyFileType.unknown:
      return FileEntryType.unknown;
    case PassyFileType.text:
      return FileEntryType.plainText;
    case PassyFileType.markdown:
      return FileEntryType.markdown;
    case PassyFileType.photo:
      return FileEntryType.photo;
  }
}
