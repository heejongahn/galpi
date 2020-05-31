import 'package:flutter/material.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

typedef OnConfirm = void Function();

enum LoginStatus {
  idle,
  verifying,
}

const rectBorder = RoundedRectangleBorder(
  side: BorderSide(color: Colors.black87),
  borderRadius: BorderRadius.all(
    Radius.circular(4),
  ),
);

class _AuthState extends State<Auth> {
  String _email;
  LoginStatus _loginStatus = LoginStatus.idle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: null,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: CommonForm(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: const Logo(
                  fontSize: 90,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 48),
                child: Text(
                  '갈피에 오신 것을 환영합니다.\n메일 주소로 로그인하고\n아름다운 독서 기록을 남기세요.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              loginBody,
            ],
          ),
        ),
      ),
    );
  }

  Widget get loginBody {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofocus: true,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: '메일 주소',
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
            onSubmitted: _loginStatus == LoginStatus.idle
                ? (value) {
                    _onContinue();
                  }
                : null,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 48,
          child: FlatButton(
            shape: rectBorder,
            onPressed: _loginStatus == LoginStatus.idle ? _onContinue : null,
            child: const Text('계속하기'),
            color: Colors.white,
            textColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _onContinue() async {
    setState(() {
      _loginStatus = LoginStatus.verifying;
    });

    try {
      final navigator = Navigator.of(context);
      final userRepository = Provider.of<UserRepository>(context);

      final doesUserExist =
          await userRepository.checkIfUserExists(email: _email);

      if (doesUserExist) {
        navigator.pushNamed('/auth/login', arguments: _email);
      } else {
        navigator.pushNamed('/auth/register', arguments: _email);
      }
    } finally {
      setState(() {
        _loginStatus = LoginStatus.idle;
      });
    }
  }
}
