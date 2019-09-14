import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const KR_DIAL_CODE = '+82';
final FirebaseAuth _auth = FirebaseAuth.instance;

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String _verificationId;
  String _message = '대기중';
  String _phoneNumber = '';
  String _code = '';

  @override
  void initState() {
    super.initState();

    _auth.currentUser().then((currentUser) => {
          if (currentUser != null)
            {
              setState(() {
                _message = '이미 로그인 됨';
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Row(children: [
                Text(_message),
              ]),
            ),
            Row(children: [
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '휴대폰 번호',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String phoneNumber) {
                    setState(() {
                      _phoneNumber = phoneNumber;
                    });
                  },
                ),
              ),
              RaisedButton(
                child: Text('보내기'),
                onPressed: _onAuth,
              ),
            ]),
            Row(children: [
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: '6자리 인증번호',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String code) {
                    setState(() {
                      _code = code;
                    });
                  },
                ),
              ),
              RaisedButton(
                child: Text('인증'),
                onPressed: _signInWithPhoneNumber,
              ),
            ]),
            RaisedButton(
              child: Text('로그아웃'),
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  _onAuth() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${_phoneNumber} (으)로 인증번호를 발송했습니다.'),
      ));
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
      phoneNumber: '${KR_DIAL_CODE}${_phoneNumber}',
      timeout: Duration(seconds: 5 * 60),
      codeSent: codeSent,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _code,
    );

    try {
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      setState(() {
        if (user != null) {
          _message = '로그인됨: uid: ${user.uid}';
        } else {
          _message = '로그인 실패';
        }
      });
    } catch (e) {
      setState(() {
        _message = '잘못된 인증번호';
      });
    }
  }

  _signOut() async {
    await _auth.signOut();
    setState(() {
      _message = '로그아웃됨';
    });
  }
}
