import 'package:flutter/material.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailPasswordRegister extends StatefulWidget {
  final String email;

  const EmailPasswordRegister({this.email});

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
                    '처음 오셨군요!',
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
                      const TextSpan(text: ' 으로 계정을 만듭니다.'),
                    ],
                  ),
                ),
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
      email: widget.email,
      password: _password,
    );

    setState(() {
      _status = LoginStatus.idle;
    });

    if (authResult.item1) {
      showMaterialSnackbar(
        context,
        '성공적으로 가입되었습니다.',
      );
    } else {
      switch (authResult.item2) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          {
            showMaterialSnackbar(
              context,
              '${widget.email}는 이미 사용 중인 메일 주소입니다. 로그인해주세요.',
            );
            Navigator.of(context).pushReplacementNamed(
              '/auth/login',
              arguments: widget.email,
            );
            return;
          }
        case 'ERROR_WEAK_PASSWORD':
          {
            showMaterialSnackbar(
              context,
              '너무 쉬운 비밀번호입니다. 더 강력한 비밀번호로 다시 시도해주세요.',
            );
            return;
          }
        default:
          {
            showMaterialSnackbar(
              context,
              '회원가입에 실패했습니다. 다시 시도해주세요.',
            );
            return;
          }
      }
    }
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
                const Text('인증 메일을 통해 회원가입'),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _onSendEmail() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    showMaterialSnackbar(context, '회원가입을 위한 인증 메일을 발송합니다.');

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
