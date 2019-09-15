import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef Future<String> RequestSms(String PhoneNumber);
typedef Future<bool> SignIn(String verificationId, String smsCode);

const KR_DIAL_CODE = '+82';

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

  Future<String> requestSms({String phoneNumber}) {
    Completer<String> _completer = new Completer();

    codeSent(String validationId, [int forceResendingToken]) {
      _completer.complete(validationId);
    }

    _auth.verifyPhoneNumber(
      phoneNumber: '${KR_DIAL_CODE}${phoneNumber}',
      timeout: Duration(seconds: 5 * 60),
      codeSent: codeSent,
      /** 
       * TODO:
       * verificationCompleted: verificationCompleted,
       * verificationFailed: verificationFailed,
       * codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      */
    );

    return _completer.future;
  }

  Future<bool> signIn({String verificationId, String smsCode}) async {
    try {
      _status = AuthStatus.Authenticating;
      notifyListeners();
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
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
