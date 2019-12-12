import 'package:package_info/package_info.dart';

enum Flavor { dev, prod }

Flavor _cachedFlavor;

Future<Flavor> getCurrentFlavor() async {
  if (_cachedFlavor != null) {
    return _cachedFlavor;
  }

  final packageInfo = await PackageInfo.fromPlatform();
  final packageName = packageInfo.packageName;
  final isDev = packageName.endsWith('.dev');

  return isDev ? Flavor.dev : Flavor.prod;
}

Future<bool> isFlavorDev() async {
  final flavor = await getCurrentFlavor();
  return flavor == Flavor.dev;
}
