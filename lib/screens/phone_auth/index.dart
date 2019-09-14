import 'package:flutter/material.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String _verificationId;
  String _phoneNumber = '';
  String _smsCode = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, userRepository, child) {
      requestSms(String phoneNumber) async {
        return userRepository.requestSms(
          phoneNumber: phoneNumber,
        );
      }

      signIn(String verificationId, String smsCode) {
        return userRepository.signIn(
          verificationId: verificationId,
          smsCode: smsCode,
        );
      }

      signOut() {
        return userRepository.signOut();
      }

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
                  Text(userRepository.authStatus.toString()),
                ]),
              ),
              buildPhoneNumberRow(requestSms),
              buildSmsCodeRow(signIn, context),
            ],
          ),
        ),
      );
    });
  }

  Widget buildPhoneNumberRow(Future<String> requestSms(String phoneNumber)) {
    return Row(children: [
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
        onPressed: () async {
          final verificationId = await requestSms(_phoneNumber);
          _verificationId = verificationId;
        },
      ),
    ]);
  }

  Widget buildSmsCodeRow(
      Future<bool> signIn(String verificationId, String smsCode),
      BuildContext context) {
    return Row(children: [
      Flexible(
        child: TextField(
          decoration: InputDecoration(
            labelText: '6자리 인증번호',
            border: OutlineInputBorder(),
          ),
          onChanged: (String code) {
            setState(() {
              _smsCode = code;
            });
          },
        ),
      ),
      RaisedButton(
          child: Text('인증'),
          onPressed: () async {
            final success = await signIn(
              _verificationId,
              _smsCode,
            );

            if (success) {
              Navigator.of(context).pop();
            }
          }),
    ]);
  }
}
