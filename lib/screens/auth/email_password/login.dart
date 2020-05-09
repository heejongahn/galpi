import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailPasswordLogin extends StatefulWidget {
  @override
  _EmailPasswordLoginState createState() => _EmailPasswordLoginState();
}

enum LoginStatus {
  idle,
  verifying,
}

const passwordMinLength = 8;

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  final _passwordFocusNode = FocusNode();

  String _email = '';
  String _password = '';
  LoginStatus _status = LoginStatus.idle;

  bool get _canConfirm {
    if (_status != LoginStatus.idle) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Logo(),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: CommonForm(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '로그인',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Text(
                  '메일 주소와 비밀번호를 입력하세요.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    final authResult = await userRepository.loginWithEmailAndPassword(
      email: _email,
      password: _password,
    );

    setState(() {
      _status = LoginStatus.idle;
    });

    if (authResult.item1) {
      _showSnackBar('성공적으로 로그인 되었습니다.');
    } else {
      switch (authResult.item2) {
        case 'ERROR_USER_NOT_FOUND':
          {
            _showSnackBar('해당 계정이 존재하지 않습니다. 아직 가입 전이라면 먼저 회원가입부터 진행해주세요.');
            return;
          }
        case 'ERROR_WRONG_PASSWORD':
          {
            _showSnackBar('비밀번호가 올바르지 않습니다. 확인 후 다시 시도해주세요.');
            return;
          }
        default:
          {
            _showSnackBar('로그인에 실패했습니다. 다시 시도해주세요.');
            return;
          }
      }
    }
  }

  Widget _buildEmailRow() {
    return Container(
      padding: const EdgeInsets.only(
        top: 24,
      ),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        enabled: _status != LoginStatus.verifying,
        autofocus: true,
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: '이메일 주소',
        ),
        onChanged: (String email) {
          setState(() {
            _email = email;
            _status = LoginStatus.idle;
          });
        },
        onSubmitted: (value) {
          _passwordFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: TextField(
        focusNode: _passwordFocusNode,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: '비밀번호',
        ),
        onChanged: (String password) {
          setState(() {
            _password = password;
            _status = LoginStatus.idle;
          });
        },
        onSubmitted: (value) {
          if (_canConfirm) {
            _onLogin();
          }
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48),
          height: 48,
          child: RaisedButton(
            onPressed: _canConfirm ? _onLogin : null,
            child: const Text('로그인'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
