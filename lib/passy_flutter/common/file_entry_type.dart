import 'package:passy/passy_data/passy_file_type.dart';

enum FileEntryType {
  unknown,
  folder,
  file,
  plainText,
  markdown,
  photo,
  audio,
  video,
  pdf,
}

PassyFileType? passyFileTypeFromFileEntryType(FileEntryType type) {
  switch (type) {
    case FileEntryType.unknown:
      return PassyFileType.unknown;
    case FileEntryType.folder:
      return null;
    case FileEntryType.file:
      return PassyFileType.unknown;
    case FileEntryType.plainText:
      return PassyFileType.text;
    case FileEntryType.markdown:
      return PassyFileType.markdown;
    case FileEntryType.photo:
      return PassyFileType.photo;
    case FileEntryType.audio:
      return PassyFileType.audio;
    case FileEntryType.video:
      return PassyFileType.video;
    case FileEntryType.pdf:
      return PassyFileType.pdf;
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
    case PassyFileType.audio:
      return FileEntryType.audio;
    case PassyFileType.video:
      return FileEntryType.video;
    case PassyFileType.pdf:
      return FileEntryType.pdf;
  }
}
