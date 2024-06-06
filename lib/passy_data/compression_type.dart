enum CompressionType {
  none,
  tar,
  zlib,
  gzip,
  bzip2,
}

CompressionType? compressionTypeFromName(String name) {
  switch (name) {
    case 'none':
      return CompressionType.none;
    case 'tar':
      return CompressionType.tar;
    case 'zlib':
      return CompressionType.zlib;
    case 'gzip':
      return CompressionType.gzip;
    case 'bzip2':
      return CompressionType.bzip2;
    default:
      return null;
  }
}
