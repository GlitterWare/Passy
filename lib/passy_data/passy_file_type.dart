enum PassyFileType {
  unknown,
  imageRaster,
}

PassyFileType? passyFileTypeFromName(String name) {
  switch (name) {
    case 'unknown':
      return PassyFileType.unknown;
    case 'imageRaster':
      return PassyFileType.imageRaster;
  }
  return null;
}
