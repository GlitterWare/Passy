import 'hashing_info.dart';

class Argon2Info extends KeyDerivationInfo {
  int parallelism;
  int memory;
  int iterations;

  Argon2Info({
    this.parallelism = 4,
    this.memory = 64,
    this.iterations = 2,
  });

  factory Argon2Info.fromJson(Map<String, dynamic> json) {
    return Argon2Info(
      parallelism: json['parallelism'] ?? 4,
      memory: json['memory'] ?? 64,
      iterations: json['iterations'] ?? 2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'parallelism': parallelism,
      'memory': memory,
      'iterations': iterations,
    };
  }
}
