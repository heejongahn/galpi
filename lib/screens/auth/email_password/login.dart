import 'package:flutter/material.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailPasswordLogin extends StatefulWidget {
  final String email;

  const EmailPasswordLogin({this.email});

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

  String _password = '';
  LoginStatus _status = LoginStatus.idle;

  bool get _canConfirm {
    if (_status != LoginStatus.idle) {
      return false;
    }

    return _password.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Logo(),
        centerTitle: false,
        actions: [
          FlatButton(
            child: const Text('비밀번호 찾기'),
            onPressed: _status != LoginStatus.idle ? null : _onPasswordReset,
          ),
        ],
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
                    '다시 오셨군요!',
                    style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.black,
                        ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' 으로 로그인합니다.'),
                    ],
                  ),
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .subtitle2
                  //     .copyWith(color: Colors.black87),
                ),
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
      email: widget.email,
      password: _password,
    );

    if (authResult.item1) {
      return;
    }

    setState(() {
      _status = LoginStatus.idle;
    });

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

  Widget _buildPasswordRow() {
    return Container(
      padding: const EdgeInsets.only(
        top: 48,
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
          margin: const EdgeInsets.only(top: 24),
          height: 48,
          child: RaisedButton(
            onPressed: _canConfirm ? _onLogin : null,
            child: const Text('로그인'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            children: <Widget>[
              const Expanded(child: Divider()),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: const Text("또는"),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        Container(
          height: 48,
          child: FlatButton(
            onPressed: _status != LoginStatus.idle ? null : _onSendEmail,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.mail),
                ),
                const Text('인증 메일을 통해 로그인'),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onPasswordReset() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    showMaterialSnackbar(context, '비밀번호 재설정 메일을 발송합니다.');
    final email = widget.email;

    try {
      await userRepository.sendPasswordResetEmail(email: email);
      Scaffold.of(context).removeCurrentSnackBar();

      showMaterialSnackbar(
        context,
        '${email}으로 메일을 발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
      );
    } catch (e) {
      showMaterialSnackbar(context, '메일 발송 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }

  Future<void> _onSendEmail() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    showMaterialSnackbar(context, '로그인을 위한 인증 메일을 발송합니다.');

    try {
      final success = await userRepository.sendLoginEmail(email: widget.email);
      Scaffold.of(context).removeCurrentSnackBar();

      if (success) {
        showMaterialSnackbar(
          context,
          '${widget.email}으로 인증 메일을 발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
        );
      } else {
        showMaterialSnackbar(context, '메일 발송 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      showMaterialSnackbar(context, '메일 발송 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }
}
