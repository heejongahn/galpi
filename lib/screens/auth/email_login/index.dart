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

class _EmailLoginState extends State<EmailLogin> {
  String _email = '';
  bool isVerificationMailSent = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        onSignIn() async {
          setState(() {
            isVerificationMailSent = true;
          });

          final success = await userRepository.sendLoginEmail(email: _email);

          if (success) {
            _showSnackbar('${_email}로 인증 메일을 발송했습니다. 메일을 확인해주세요.');
          } else {
            _showSnackbar('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
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
        ),
        onChanged: (String email) {
          setState(() {
            _email = email;
          });
        },
      ),
    );
  }

  buildConfirmButton({OnConfirm onConfirm}) {
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 48,
          child: RaisedButton(
            onPressed: onConfirm,
            child: Text('로그인'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
      ),
    ]);
  }

  _showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
