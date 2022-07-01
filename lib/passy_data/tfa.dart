import 'package:otp/otp.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/csv_convertable.dart';
import 'package:passy/passy_data/json_convertable.dart';

Algorithm? algorithmFromName(String name) {
  switch (name) {
    case 'SHA1':
      return Algorithm.SHA1;
    case 'SHA256':
      return Algorithm.SHA256;
    case 'SHA512':
      return Algorithm.SHA512;
  }
  return null;
}

class TFA with JsonConvertable, CSVConvertable {
  String secret;
  int length;
  int interval;
  Algorithm algorithm;
  bool isGoogle;

  TFA({
    this.secret = '',
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
    this.isGoogle = true,
  });

  TFA.fromJson(Map<String, dynamic> json)
      : secret = json['secret'],
        length = json['length'],
        interval = json['interval'],
        algorithm = algorithmFromName(json['algorithm']) ?? Algorithm.SHA1,
        isGoogle = true;

  TFA.fromCSV(List csv)
      : secret = csv[0],
        length = int.tryParse(csv[1]) ?? 6,
        interval = int.tryParse(csv[2]) ?? 30,
        algorithm = algorithmFromName(csv[3]) ?? Algorithm.SHA1,
        isGoogle = boolFromString(csv[4]) ?? true;

  @override
  Map<String, dynamic> toJson() => {
        'secret': secret,
        'length': length,
        'interval': interval,
        'algorithm': algorithm.name,
        'isGoogle': isGoogle,
      };

  @override
  List toCSV() => [
        secret,
        length.toString(),
        interval.toString(),
        algorithm.name,
        isGoogle.toString(),
      ];
}
