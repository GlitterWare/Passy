import 'dart:io';

class HostAddress {
  final InternetAddress ip;
  final int port;

  @override
  String toString() => '${ip.address}:$port';

  HostAddress(this.ip, this.port);

  factory HostAddress.parse(String value) {
    List<String> _formatted = value.split(':');
    return (HostAddress(
        InternetAddress(_formatted[0]), int.parse(_formatted[1])));
  }

  static HostAddress? tryParse(String value) {
    try {
      return HostAddress.parse(value);
    } catch (e) {
      return null;
    }
  }
}
