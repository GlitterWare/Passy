enum PassyFileType {
  unknown,
  text,
  markdown,
  imageRaster,
}

PassyFileType? passyFileTypeFromName(String name) {
  switch (name) {
    case 'unknown':
      return PassyFileType.unknown;
    case 'text':
      return PassyFileType.text;
    case 'markdown':
      return PassyFileType.markdown;
    case 'imageRaster':
      return PassyFileType.imageRaster;
  }
  return null;
}
