class GlareModule {
  final String name;
  final Future<Map<String, dynamic>?> Function(
    List<String> args, {
    required void Function(String key, GlareModule module) addModule,
    Map<String, List<int>>? binaryObjects,
  }) target;

  GlareModule({
    required this.name,
    required this.target,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  Future<Map<String, dynamic>?> run(
    List<String> args, {
    required void Function(String key, GlareModule module) addModule,
    Map<String, List<int>>? binaryObjects,
  }) =>
      target(
        args,
        addModule: addModule,
        binaryObjects: binaryObjects,
      );
}
