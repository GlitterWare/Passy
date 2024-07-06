enum PassyFileType {
  unknown,
  text,
  markdown,
  photo,
  audio,
  video,
}

PassyFileType? passyFileTypeFromName(String name) {
  switch (name) {
    case 'unknown':
      return PassyFileType.unknown;
    case 'text':
      return PassyFileType.text;
    case 'markdown':
      return PassyFileType.markdown;
    case 'photo':
      return PassyFileType.photo;
    case 'imageRaster':
      return PassyFileType.photo;
    case 'audio':
      return PassyFileType.audio;
    case 'video':
      return PassyFileType.video;
  }
  return null;
}
