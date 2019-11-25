import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galpi/constants.dart';

typedef Future<String> RequestSms(String PhoneNumber);
typedef Future<bool> SignIn(String verificationId, String smsCode);

const KR_DIAL_CODE = '+82';

enum SendSmsStatus { CodeSent, AlreadyVerified, Error }

class SendSmsResult {
  @required
  SendSmsStatus status;
  String verificationId;
  AuthCredential authCredential;
  AuthException authException;

  SendSmsResult(
      {this.status,
      this.verificationId,
      this.authCredential,
      this.authException});
}

enum AuthStatus {
  Unauthenticated,
  Authenticated,
}

class UserRepository extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  FirebaseUser get user => _user;

  UserRepository() {
    initialize();
  }

  initialize() async {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
    _user = await _auth.currentUser();

    if (_user != null) {
      _user.reload();
    }
  }

  AuthStatus get authStatus {
    if (_user == null) {
      return AuthStatus.Unauthenticated;
    }

    return AuthStatus.Authenticated;
  }

  bool get isLoggedIn => authStatus == AuthStatus.Authenticated;

  Future<bool> sendLoginEmail({
    String email,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      final isDev = packageName.endsWith('.dev');
      final sharedPreference = await SharedPreferences.getInstance();

      await sharedPreference.setString(
        SHARED_PREFERENCE_LOGIN_EMAIL,
        email,
      );

      await _auth.sendSignInWithEmailLink(
        handleCodeInApp: true,
        email: email,
        url: 'https://${isDev ? 'galpi-dev' : 'galpi'}.firebaseapp.com/',
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
      final sharedPreference = await SharedPreferences.getInstance();

      await _auth.signInWithEmailAndLink(email: email, link: link);
      await sharedPreference.remove(SHARED_PREFERENCE_LOGIN_EMAIL);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future signOut() async {
    await _auth.signOut();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    _user = firebaseUser;
    notifyListeners();
  }

  Future<void> reload() {
    if (_user != null) {
      _user.reload();
    }
  }
}

final userRepository = new UserRepository();
