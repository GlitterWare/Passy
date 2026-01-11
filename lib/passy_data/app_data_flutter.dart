import 'package:path_provider/path_provider.dart';

class Locator {
  static Future<String> getPlatformSpecificCachePath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
