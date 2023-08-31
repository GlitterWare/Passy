import 'package:passy/passy_data/json_convertable.dart';

class Sync2d0d0ServerInfo with JsonConvertable {
  String nickname;
  String address;
  int port;

  Sync2d0d0ServerInfo({
    required this.nickname,
    required this.address,
    required this.port,
  });

  Sync2d0d0ServerInfo.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'] ?? DateTime.now().toUtc().toIso8601String(),
        address = json['address'] ?? '',
        port = json.containsKey('port')
            ? (int.tryParse(json['port']) ?? 5592)
            : 5592;

  @override
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'address': address,
      'port': port,
    };
  }
}
