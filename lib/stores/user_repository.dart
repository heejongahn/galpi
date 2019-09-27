import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated
}

class UserRepository extends ChangeNotifier {
  FirebaseAuth _auth;
  FirebaseUser _user;
  AuthStatus _status = AuthStatus.Uninitialized;

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  AuthStatus get authStatus => _status;
  FirebaseUser get user => _user;
  bool get isAuthenticated => _status == AuthStatus.Authenticated;

  Future<SendSmsResult> requestSms({String phoneNumber}) {
    Completer<SendSmsResult> _completer = new Completer();

    codeSent(String verificationId, [int forceResendingToken]) {
      _completer.complete(SendSmsResult(
          status: SendSmsStatus.CodeSent, verificationId: verificationId));
    }

    verificationCompleted(AuthCredential authCredential) {
      _completer.complete(SendSmsResult(
          status: SendSmsStatus.AlreadyVerified,
          authCredential: authCredential));
    }

    verificationFailed(AuthException authException) {
      _completer.complete(SendSmsResult(
          status: SendSmsStatus.Error, authException: authException));
    }

    _auth.verifyPhoneNumber(
      phoneNumber: '${KR_DIAL_CODE}${phoneNumber}',
      timeout: Duration(seconds: 2 * 60),
      codeSent: codeSent,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      /** 
       * TODO:
       * codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      */
    );

    return _completer.future;
  }

  Future<bool> signInWithPhone({String verificationId, String smsCode}) async {
    _status = AuthStatus.Authenticating;
    notifyListeners();
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return signinWithCredential(credential);
  }

  Future<bool> signinWithCredential(AuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    await _auth.signOut();
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future onSetDisplayName({String displayName}) async {
    if (_user == null) {
      return;
    }

    final UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = displayName;
    await _user.updateProfile(userUpdateInfo);
    _user = await _auth.currentUser();
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = AuthStatus.Authenticated;
    }
    notifyListeners();
  }
}
