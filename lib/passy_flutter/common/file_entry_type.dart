import 'package:passy/passy_data/passy_file_type.dart';

enum FileEntryType {
  unknown,
  file,
  plainText,
  markdown,
  imageRaster,
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
    case FileEntryType.imageRaster:
      return PassyFileType.imageRaster;
    case FileEntryType.folder:
      return null;
  }
}
