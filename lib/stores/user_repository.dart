import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galpi/models/user.dart';
import 'package:galpi/remotes/me.dart';
import 'package:galpi/remotes/register.dart';
import 'package:galpi/utils/flavor.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:package_info/package_info.dart';
import 'package:galpi/constants.dart';

final secureStorage = new FlutterSecureStorage();

enum AuthStatus {
  Unauthenticated,
  Authenticated,
}

class UserRepository extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  User _user;

  User get user => _user;
  set user(User user) {
    _user = user;
    notifyListeners();
  }

  AuthStatus get authStatus {
    if (user == null) {
      return AuthStatus.Unauthenticated;
    }

    return AuthStatus.Authenticated;
  }

  bool get isLoggedIn => authStatus == AuthStatus.Authenticated;

  UserRepository() {
    _initialize();
  }

  _initialize() async {
    String loginToken = await secureStorage.read(key: AUTH_LOGIN_TOKEN_KEY);

    if (loginToken != null) {
      await _login(loginToken);
    }
  }

  Future<bool> sendLoginEmail({
    String email,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final isDev = await isFlavorDev();
    final sharedPreference = await SharedPreferences.getInstance();

    await sharedPreference.setString(
      SHARED_PREFERENCE_LOGIN_EMAIL,
      email,
    );

    try {
      await _auth.sendSignInWithEmailLink(
        handleCodeInApp: true,
        email: email,
        url: 'https://${isDev ? 'galpi-dev' : 'galpi-f7dd7'}.firebaseapp.com/',
        iOSBundleID: packageName,
        androidPackageName: packageName,
        androidInstallIfNotAvailable: true,
        androidMinimumVersion: '4.4',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithEmail({
    String email,
    String link,
  }) async {
    try {
      final authResult =
          await _auth.signInWithEmailAndLink(email: email, link: link);

      if (authResult.user == null) {
        return false;
      }

      final firebaseToken = (await authResult.user.getIdToken()).token;
      final token = await registerWithFirebase(token: firebaseToken);
      return _login(token);
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _login(String token) async {
    final sharedPreference = await SharedPreferences.getInstance();

    try {
      httpClient.token = token;
      user = await me();

      await Future.wait([
        secureStorage.write(key: AUTH_LOGIN_TOKEN_KEY, value: token),
        sharedPreference.remove(SHARED_PREFERENCE_LOGIN_EMAIL),
      ]);

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  logout() async {
    await _auth.signOut();
    httpClient.token = null;
    user = null;
    secureStorage.delete(key: AUTH_LOGIN_TOKEN_KEY);
  }
}

final userRepository = new UserRepository();
