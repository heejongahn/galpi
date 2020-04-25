import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/constants.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

typedef OnConfirm = void Function();

enum LoginStatus {
  idle,
  sendingEmail,
  sentEmail,
  verifying,
}

class _EmailLoginState extends State<EmailLogin> {
  String _email = '';
  LoginStatus _status = LoginStatus.idle;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        Future<void> onSignIn() async {
          final isResending = _status != LoginStatus.idle;

          _showSnackBar('인증 메일을 ${isResending ? '다시 ' : ''}발송합니다.');

          setState(() {
            _status = LoginStatus.sendingEmail;
          });

          final success = await userRepository.sendLoginEmail(email: _email);
          _removeCurrentSnackBar();

          if (success) {
            _showSnackBar(
              '${_email}로 인증 메일을 ${isResending ? '다시 ' : ''}발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
            );
            setState(() {
              _status = LoginStatus.sentEmail;
            });
          } else {
            _showSnackBar('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
            setState(() {
              _status = LoginStatus.idle;
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Logo(),
            centerTitle: false,
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: CommonForm(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '환영합니다!',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Text(
                    '이메일 주소로 간편하게 로그인하고\n아름다운 독서 기록을 남기세요',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  _buildEmailRow(),
                  _buildConfirmButton(onConfirm: onSignIn),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: TextField(
        enabled: _status != LoginStatus.verifying,
        autofocus: true,
        decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: '이메일 주소',
            helperText: _status == LoginStatus.idle ||
                    _status == LoginStatus.sendingEmail
                ? ''
                : '${_email}로 인증 메일이 발송되었습니다.'),
        onChanged: (String email) {
          setState(() {
            _email = email;
            _status = LoginStatus.idle;
          });
        },
      ),
    );
  }

  Widget _buildConfirmButton({OnConfirm onConfirm}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: RaisedButton(
            onPressed: _status == LoginStatus.idle ? onConfirm : null,
            child: const Text('인증 메일 발송'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
        _status != LoginStatus.idle
            ? Container(
                margin: const EdgeInsets.only(top: 12),
                height: 48,
                child: FlatButton(
                  onPressed:
                      _status != LoginStatus.sendingEmail ? onConfirm : null,
                  child: const Text('메일을 받지 못하셨나요?'),
                ),
              )
            : Container(width: 0, height: 0),
      ],
    );
  }

  void _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _removeCurrentSnackBar() {
    Scaffold.of(context).removeCurrentSnackBar();
  }

  Future<void> _initializeFirebaseDynamicLinks() async {
    final firebaseDLInstance = FirebaseDynamicLinks.instance;

    await firebaseDLInstance.getInitialLink().then((data) {
      if (data != null) {
        _loginIfAvailable(data.link);
      }
    });

    firebaseDLInstance.onLink(
      onSuccess: (data) async {
        _loginIfAvailable(data.link);
      },
      onError: (error) async {
        print(error);
      },
    );
  }

  Future<void> _loginIfAvailable(Uri link) async {
    if (userRepository.user != null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final email = sharedPreference.getString(SHARED_PREFERENCE_LOGIN_EMAIL);

    if (email == null) {
      return;
    }

    setState(() {
      _status = LoginStatus.verifying;
    });

    _showSnackBar(
      '${email}으로 로그인 중',
    );

    try {
      final success = await userRepository.loginWithEmail(
        email: email,
        link: link.toString(),
      );

      _removeCurrentSnackBar();
      if (success) {
        _showSnackBar('${email}으로 로그인 되었습니다.');
      } else {
        throw Error();
      }
    } catch (e) {
      print(e);
      _showSnackBar('로그인에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }
}
