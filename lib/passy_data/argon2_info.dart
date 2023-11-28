import 'dart:convert';

import 'package:dargon2_interface/dargon2_interface.dart';

import 'key_derivation_info.dart';

class Argon2Info extends KeyDerivationInfo {
  Salt salt;
  int parallelism;
  int memory;
  int iterations;

  Argon2Info({
    required this.salt,
    this.parallelism = 4,
    this.memory = 65536,
    this.iterations = 2,
  });

  factory Argon2Info.fromJson(Map<String, dynamic> json) {
    return Argon2Info(
      salt: Salt(base64Decode(json['salt'])),
      parallelism: json['parallelism'] ?? 4,
      memory: json['memory'] ?? 64,
      iterations: json['iterations'] ?? 2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    String saltEncoded = base64Encode(salt.bytes);
    return {
      'salt': saltEncoded,
      'parallelism': parallelism,
      'memory': memory,
      'iterations': iterations,
    };
  }

  @override
  List toCSV() {
    String saltEncoded = base64Encode(salt.bytes);
    return [
      saltEncoded,
      parallelism,
      memory,
      iterations,
    ];
  }
}
