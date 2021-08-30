import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoHandler {
  static PackageInfo? _packageInfo;

  static void _checkStatus() {
    if (_packageInfo == null) {
      throw Exception(
          "PackInfoHandler not initialized, initialize with [PackageInfoHandler.initialize()]");
    }
  }

  static bool get isDeveloperVersion {
    _checkStatus();
    return _packageInfo!.packageName.endsWith(".dev");
  }

  static String get appName {
    _checkStatus();
    return _packageInfo!.appName;
  }

  static String get buildNumber {
    _checkStatus();
    return _packageInfo!.buildNumber;
  }

  static String get packageName {
    _checkStatus();
    return _packageInfo!.packageName;
  }

  static String get version {
    _checkStatus();
    return _packageInfo!.version;
  }

  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
