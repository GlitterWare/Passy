import 'package:passy/passy_data/csv_convertable.dart';

import 'argon2_info.dart';
import 'json_convertable.dart';
import 'key_derivation_type.dart';

abstract class KeyDerivationInfo with JsonConvertable, CSVConvertable {
  static KeyDerivationInfo Function(Map<String, dynamic> json)? fromJson(
      KeyDerivationType type) {
    switch (type) {
      case KeyDerivationType.none:
        return null;
      case KeyDerivationType.argon2:
        return Argon2Info.fromJson;
    }
  }
}
