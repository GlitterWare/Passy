import 'package:passy/passy_data/json_convertable.dart';

class BiometricStorageData with JsonConvertable {
  final String key;
  String password;

  BiometricStorageData({
    required this.key,
    this.password = '',
  });

  BiometricStorageData.fromJson(
      {required this.key, required Map<String, dynamic> json})
      : password = json['password'] ?? '';

  @override
  Map<String, dynamic> toJson() => {
        'password': password,
      };
}
