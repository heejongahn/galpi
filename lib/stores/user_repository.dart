import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:galpi/remotes/renew.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/models/user.dart';
import 'package:galpi/remotes/edit_profile.dart';
import 'package:galpi/remotes/me.dart';
import 'package:galpi/remotes/register.dart';
import 'package:galpi/utils/flavor.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/constants.dart';

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
    _auth.onAuthStateChanged.listen((newFirebaseUser) {
      firebaseUser = newFirebaseUser;
      notifyListeners();
    });

    print('userRepository.initialize');

    final String loginToken =
        await secureStorage.read(key: AUTH_LOGIN_TOKEN_KEY);

    await reloadFirebaseUser();

    // // 1. Try login
    if (loginToken != null) {
      print('userRepository.initialize.tryLogin');
      final authResult = await _loginWithToken(token: loginToken);

      // Login success
      if (authResult.item1) {
        return;
      }
    }

    // 2. Try token renewal
    final String refreshToken =
        await secureStorage.read(key: AUTH_REFRESH_TOKEN_KEY);

    if (refreshToken != null) {
      print('userRepository.initialize.tryRefresh');
      final renewResult = await _renewWithToken(refreshToken: refreshToken);

      if (renewResult) {
        return;
      }
    }

    print('userRepository.initialize.logout');
    // 3. Not logged in
    await logout();
  }

  Future<void> sendVerificationEmail() async {
    if (firebaseUser == null) {
      return;
    }

    await firebaseUser.sendEmailVerification();
  }

  Future<bool> checkIfUserExists({String email}) async {
    final signInMethods = await _auth.fetchSignInMethodsForEmail(email: email);
    return signInMethods.isNotEmpty;
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
    final authTokenPair = await registerWithFirebase(
      firebaseToken: firebaseToken,
    );

    await secureStorage.write(
      key: AUTH_REFRESH_TOKEN_KEY,
      value: authTokenPair.refreshToken,
    );

    return _loginWithToken(token: authTokenPair.token);
  }

  Future<Tuple2<bool, String>> _loginWithToken({
    String token,
  }) async {
    final sharedPreference = await SharedPreferences.getInstance();

    try {
      httpClient.token = token;
      user = await me();

      await Future.wait([
        secureStorage.write(
          key: AUTH_LOGIN_TOKEN_KEY,
          value: token,
        ),
        sharedPreference.remove(
          SHARED_PREFERENCE_LOGIN_EMAIL,
        ),
      ]);

      return const Tuple2(true, null);
    } catch (e) {
      return unknownAuthFailure;
    }
  }

  Future<bool> _renewWithToken({
    String refreshToken,
  }) async {
    try {
      final authTokenPair = await renew(refreshToken: refreshToken);

      await secureStorage.write(
        key: AUTH_REFRESH_TOKEN_KEY,
        value: authTokenPair.refreshToken,
      );

      await _loginWithToken(token: authTokenPair.token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      secureStorage.delete(key: AUTH_LOGIN_TOKEN_KEY),
      secureStorage.delete(key: AUTH_REFRESH_TOKEN_KEY),
    ]);

    httpClient.token = null;
    user = null;
  }

  Future<void> updateUser(User updatedUser) async {
    user = await editProfile(updatedUser);
  }
}
