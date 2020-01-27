import 'package:flutter/material.dart';
import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

typedef void OnConfirm();

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
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        onSignIn() async {
          final isResending = _status != LoginStatus.idle;

          _showSnackbar('인증 메일을 ${isResending ? '다시 ' : ''}발송합니다.');

          setState(() {
            _status = LoginStatus.sendingEmail;
          });

          final success = await userRepository.sendLoginEmail(email: _email);
          _removeCurrentSnackbar();

          if (success) {
            _showSnackbar(
              '${_email}로 인증 메일을 ${isResending ? '다시 ' : ''}발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
            );
            setState(() {
              _status = LoginStatus.sentEmail;
            });
          } else {
            _showSnackbar('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
            setState(() {
              _status = LoginStatus.idle;
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Logo(),
            centerTitle: false,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: CommonForm(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Text(
                      '환영합니다!',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Text(
                    '이메일 주소로 간편하게 로그인하고\n아름다운 독서 기록을 남기세요',
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  buildEmailRow(),
                  buildConfirmButton(onConfirm: onSignIn),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEmailRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 32),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
            border: UnderlineInputBorder(),
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

  buildConfirmButton({OnConfirm onConfirm}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: RaisedButton(
            onPressed: _status == LoginStatus.idle ? onConfirm : null,
            child: Text('인증 메일 발송'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
        _status != LoginStatus.idle
            ? Container(
                margin: EdgeInsets.only(top: 12),
                height: 48,
                child: FlatButton(
                  onPressed:
                      _status != LoginStatus.sendingEmail ? onConfirm : null,
                  child: Text('메일을 받지 못하셨나요?'),
                ),
              )
            : Container(width: 0, height: 0),
      ],
    );
  }

  _showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  _removeCurrentSnackbar() {
    Scaffold.of(context).removeCurrentSnackBar();
  }
}
