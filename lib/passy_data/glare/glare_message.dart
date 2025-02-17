class GlareMessage {
  Map<String, dynamic> data;
  Map<String, List<int>>? binaryObjects;

  GlareMessage(
    this.data, {
    this.binaryObjects,
  });

  factory GlareMessage.fromSocketData(Map<String, dynamic> data) {
    Map<String, List<int>>? binaryObjects;
    dynamic binaryObjectsJson = data['binaryObjects'];
    if (binaryObjectsJson != null) {
      data.remove('binaryObjects');
      binaryObjects = Map.castFrom(binaryObjectsJson);
    }
    return GlareMessage(data, binaryObjects: binaryObjects);
  }
}
