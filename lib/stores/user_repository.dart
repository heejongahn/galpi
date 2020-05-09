import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:galpi/remotes/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galpi/models/user.dart';
import 'package:galpi/remotes/me.dart';
import 'package:galpi/remotes/register.dart';
import 'package:galpi/utils/flavor.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:package_info/package_info.dart';
import 'package:galpi/constants.dart';
import 'package:tuple/tuple.dart';

const secureStorage = FlutterSecureStorage();

enum AuthStatus {
  Unauthenticated,
  NeedsEmailVerification,
  Authenticated,
}

const unknownAuthFailure = Tuple2(false, null);

class UserRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  User _user;

  User get user => _user;
  set user(User user) {
    _user = user;
    notifyListeners();
  }

  AuthStatus get authStatus {
    if (firebaseUser != null && !firebaseUser.isEmailVerified) {
      return AuthStatus.NeedsEmailVerification;
    }

    if (user != null) {
      return AuthStatus.Authenticated;
    }

    return AuthStatus.Unauthenticated;
  }

  bool get isLoggedIn {
    return authStatus == AuthStatus.Authenticated;
  }

  Future<void> initialize() async {
    final String loginToken =
        await secureStorage.read(key: AUTH_LOGIN_TOKEN_KEY);

    if (loginToken != null) {
      final authResult = await _loginWithToken(loginToken);
      if (authResult.item1) {
        return;
      }
    }

    await reloadFirebaseUser();

    _auth.onAuthStateChanged.listen((newFirebaseUser) {
      firebaseUser = newFirebaseUser;
      notifyListeners();
    });
  }

  Future<void> sendVerificationEmail() async {
    if (firebaseUser == null) {
      return;
    }

    await firebaseUser.sendEmailVerification();
  }

  Future<bool> checkIfEmailVerified() async {
    final firebaseUser = await reloadFirebaseUser();

    if (firebaseUser.isEmailVerified) {
      await _loginWithFirebaseUser(firebaseUser);
      return true;
    } else {
      return false;
    }
  }

  Future<void> sendPasswordResetEmail({String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
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

  Future<Tuple2<bool, String>> loginWithEmail({
    String email,
    String link,
  }) async {
    try {
      final authResult =
          await _auth.signInWithEmailAndLink(email: email, link: link);

      if (authResult.user == null) {
        return unknownAuthFailure;
      }

      final result = await _loginWithFirebaseUser(authResult.user);
      return result;
    } on PlatformException catch (e) {
      return Tuple2(false, e.code);
    } catch (e) {
      return unknownAuthFailure;
    }
  }

  Future<Tuple2<bool, String>> registerWithEmailAndPassword({
    String email,
    String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return const Tuple2(true, null);
    } on PlatformException catch (e) {
      return Tuple2(false, e.code);
    } catch (e) {
      return unknownAuthFailure;
    }
  }

  Future<Tuple2<bool, String>> loginWithEmailAndPassword({
    String email,
    String password,
  }) async {
    try {
      final authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final result = await _loginWithFirebaseUser(authResult.user);
      return result;
    } on PlatformException catch (e) {
      return Tuple2(false, e.code);
    } catch (e) {
      return unknownAuthFailure;
    }
  }

  Future<FirebaseUser> reloadFirebaseUser() async {
    final currentUser = await _auth.currentUser();
    await currentUser?.reload();

    firebaseUser = currentUser;

    return currentUser;
  }

  Future<Tuple2<bool, String>> _loginWithFirebaseUser(
      FirebaseUser loggingInFirebaseUser) async {
    if (loggingInFirebaseUser == null) {
      return unknownAuthFailure;
    }

    final firebaseToken = (await loggingInFirebaseUser.getIdToken()).token;
    final token = await registerWithFirebase(token: firebaseToken);
    return _loginWithToken(token);
  }

  Future<Tuple2<bool, String>> _loginWithToken(String token) async {
    final sharedPreference = await SharedPreferences.getInstance();

    try {
      httpClient.token = token;
      user = await me();

      await Future.wait([
        secureStorage.write(key: AUTH_LOGIN_TOKEN_KEY, value: token),
        sharedPreference.remove(SHARED_PREFERENCE_LOGIN_EMAIL),
      ]);

      return const Tuple2(true, null);
    } catch (e) {
      await logout();
      return unknownAuthFailure;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    httpClient.token = null;
    user = null;
    secureStorage.delete(key: AUTH_LOGIN_TOKEN_KEY);
  }

  Future<void> updateUser(User updatedUser) async {
    user = await editProfile(updatedUser);
  }
}
