import 'package:passy/passy_data/json_convertable.dart';

class BiometricStorageData with JsonConvertable {
  String password;

  BiometricStorageData({this.password = ''});

  @override
  Map<String, dynamic> toJson() => {
        'password': password,
      };
}
