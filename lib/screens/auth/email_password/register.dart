import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailPasswordRegister extends StatefulWidget {
  @override
  _EmailPasswordRegisterState createState() => _EmailPasswordRegisterState();
}

enum LoginStatus {
  idle,
  verifying,
}

const passwordMinLength = 8;

class _EmailPasswordRegisterState extends State<EmailPasswordRegister> {
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  LoginStatus _status = LoginStatus.idle;

  String get _passwordConfirmHelperText {
    if (_passwordConfirm != _password) {
      return '비밀번호와 일치하지 않습니다.';
    }

    return null;
  }

  bool get _canConfirm {
    if (_password.length < passwordMinLength) {
      return false;
    }

    if (_passwordConfirmHelperText != null) {
      return false;
    }

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
                    '회원가입',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Text(
                  '로그인에 사용할 메일 주소와 비밀번호를 입력하세요.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildPasswordConfirmRow(),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    final authResult = await userRepository.registerWithEmailAndPassword(
      email: _email,
      password: _password,
    );

    setState(() {
      _status = LoginStatus.idle;
    });

    if (authResult.item1) {
      _showSnackBar('성공적으로 가입되었습니다.');
    } else {
      switch (authResult.item2) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          {
            _showSnackBar('${_email}는 이미 사용 중인 메일 주소입니다. 로그인해주세요.');
            Navigator.of(context)
                .pushReplacementNamed('/auth/email-password/login');
            return;
          }
        case 'ERROR_WEAK_PASSWORD':
          {
            _showSnackBar('너무 쉬운 비밀번호입니다. 더 강력한 비밀번호로 다시 시도해주세요.');
            return;
          }
        default:
          {
            _showSnackBar('회원가입에 실패했습니다. 다시 시도해주세요.');
            return;
          }
      }
    }
  }

  Widget _buildEmailRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: const EdgeInsets.only(
        top: 24,
      ),
      child: TextField(
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
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

  Widget _buildPasswordRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: TextField(
        textInputAction: TextInputAction.next,
        focusNode: _passwordFocusNode,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: '비밀번호',
          helperText: '최소 ${passwordMinLength}자 이상',
        ),
        onChanged: (String password) {
          setState(() {
            _password = password;
            _status = LoginStatus.idle;
          });
        },
        onSubmitted: (value) {
          _passwordConfirmFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildPasswordConfirmRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 32,
      ),
      child: TextField(
        focusNode: _passwordConfirmFocusNode,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: '비밀번호 확인',
          helperText: _passwordConfirmHelperText,
        ),
        onChanged: (String passwordConfirm) {
          setState(() {
            _passwordConfirm = passwordConfirm;
            _status = LoginStatus.idle;
          });
        },
        onSubmitted: (value) {
          if (_canConfirm) {
            _onRegister();
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
            onPressed: _canConfirm ? _onRegister : null,
            child: const Text('회원가입'),
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
