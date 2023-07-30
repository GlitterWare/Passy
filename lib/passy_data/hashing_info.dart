import 'argon2_info.dart';
import 'json_convertable.dart';
import 'hashing_type.dart';

abstract class HashingInfo with JsonConvertable {
  static HashingInfo Function(Map<String, dynamic> json)? fromJson(
      HashingType type) {
    switch (type) {
      case HashingType.none:
        return null;
      case HashingType.argon2:
        return Argon2Info.fromJson;
      default:
        throw Exception(
            'Json conversion not supported for HashingType \'${type.name}\'');
    }
  }
}
