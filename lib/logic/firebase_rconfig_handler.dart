import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:protasks/logic/package_info_handler.dart';

class FirebaseRConfigHandler {
  static String _leastRecommendedVersion = "least_recommended_version";
  static String _forceFree = "force_free";
  static String _groupsPerAd = "groups_per_ad";
  static String _tasksPerAd = "tasks_per_ad";
  static String _chatsPerAd = "chats_per_ad";
  static String _freeToProAds = "free_to_pro_ads";
  static String _signInHostDeveloper = "sign_in_host_developer";
  static String _signInHostRelease = "sign_in_host_release";

  static String get leastRecommendedVersion =>
      instance.getString(_leastRecommendedVersion);

  static String get signInHostDeveloper =>
      instance.getString(_signInHostDeveloper);

  static String get signInHostRelease => instance.getString(_signInHostRelease);

  static bool get forceFree => instance.getBool(_forceFree);

  static int get groupsPerAd => instance.getInt(_groupsPerAd);

  static int get tasksPerAd => instance.getInt(_tasksPerAd);

  static int get chatsPerAd => instance.getInt(_chatsPerAd);

  static int get freeToProAds => instance.getInt(_freeToProAds);

  static RemoteConfig? _instance;

  static Future<void> fetchAndActivate({bool forceUpdate = false}) async {
    if ((FirebaseRConfigHandler.instance.lastFetchTime
            .add(FirebaseRConfigHandler.minimumFetchTimeout)
            .isBefore(DateTime.now())) ||
        forceUpdate) {
      await instance.fetchAndActivate();
    }
  }

  static Duration minimumFetchTimeout = const Duration(minutes: 15);

  static RemoteConfig get instance {
    if (_instance == null) {
      _instance = RemoteConfig.instance;
      _instance!.setDefaults(<String, dynamic>{
        // _leastRecommendedVersion: '0.0.1-beta',
        _leastRecommendedVersion: PackageInfoHandler.version,
        _forceFree: false,
        _groupsPerAd: 2,
        _tasksPerAd: 4,
        _chatsPerAd: 8,
        _freeToProAds: 5,
        _signInHostDeveloper: 'https://todoappdeveloperversion.page.link',
        _signInHostRelease: 'https://links.protasks.in',
      });

      _instance!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: minimumFetchTimeout,
      ));
    }

    return _instance!;
  }
}
