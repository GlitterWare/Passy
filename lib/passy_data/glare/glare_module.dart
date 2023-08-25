import 'package:passy/passy_data/glare/glare_server.dart';

class GlareModule {
  final String name;
  final Future<Map<String, dynamic>?> Function(
    List<String> args, {
    GlareServer? server,
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
    GlareServer? server,
  }) =>
      target(args, server: server);
}
