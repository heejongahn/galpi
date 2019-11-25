import 'package:flutter/material.dart';
import 'package:galpi/components/common_form/index.dart';
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
            _closeScreen();
          } else {
            _showSnackbar('로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('로그인'),
            centerTitle: false,
          ),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: CommonForm(
              child: Column(
                children: <Widget>[
                  // Text(
                  //   '로그인',
                  //   style: Theme.of(context).textTheme.title,
                  // ),
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
      padding: EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          labelText: '이메일',
          prefixIcon: Icon(Icons.email),
          filled: true,
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
    return Container(
      alignment: Alignment.centerRight,
      child: RaisedButton(
        onPressed: onConfirm,
        child: Text('로그인'),
      ),
    );
  }

  _closeScreen() {
    Navigator.of(context).pop();
  }

  _showSnackbar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
