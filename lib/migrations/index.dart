import 'package:galpi/constants.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:galpi/migrations/v1_0_4_upload_to_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

typedef Future<void> Migration();

final List<Tuple2<String, Migration>> migrationInfoList = [
  Tuple2.fromList(['1.0.4', v1_0_4_uploadToServer]),
];

Future<void> runAllNeededMigrations() async {
  final prefs = await SharedPreferences.getInstance();
  final rawLastVersion = prefs.getString(SHARED_PREFERENCE_VERSION_KEY);

  final platformInfo = await PackageInfo.fromPlatform();
  final currentVersion = Version.parse(platformInfo.version);

  if (rawLastVersion != null) {
    final lastVersion = Version.parse(rawLastVersion);

    for (Tuple2<String, Migration> migrationInfo in migrationInfoList) {
      final rawVersion = migrationInfo.item1;
      final migration = migrationInfo.item2;

      final version = Version.parse(rawVersion);

      if (lastVersion < version && version <= currentVersion) {
        await migration();
      }
    }
  }

  await prefs.setString(
    SHARED_PREFERENCE_VERSION_KEY,
    currentVersion.toString(),
  );
}
