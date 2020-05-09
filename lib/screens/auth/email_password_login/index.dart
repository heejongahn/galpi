import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailPasswordLogin extends StatefulWidget {
  final Map<String, bool> arguments;

  const EmailPasswordLogin({@required this.arguments});

  @override
  _EmailPasswordLoginState createState() => _EmailPasswordLoginState();
}

typedef OnConfirm = void Function();

enum LoginStatus {
  idle,
  verifying,
}

const passwordMinLength = 8;

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  bool _forceLoginView = false;
  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  LoginStatus _status = LoginStatus.idle;

  String get _passwordHelperText {
    if (_isRegistering) {
      return null;
    }

    if (_password.length < passwordMinLength) {
      return '최소 ${passwordMinLength}자 이상';
    }

    return null;
  }

  String get _passwordConfirmHelperText {
    if (!_isRegistering) {
      return null;
    }

    if (_passwordConfirm != _password) {
      return '비밀번호가 일치하지 않습니다.';
    }

    return null;
  }

  bool get _isRegistering {
    return !_forceLoginView && widget.arguments['isRegistering'];
  }

  String get _actionLabel {
    return _isRegistering ? '회원가입' : '로그인';
  }

  bool get _canConfirm {
    if (_passwordConfirmHelperText != null) {
      return false;
    }

    if (_passwordHelperText != null) {
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
                    _isRegistering ? '메일 주소와 비밀번호로 회원가입' : '메일 주소와 비밀번호로 로그인',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Text(
                  '로그인에 사용할 메일 주소와 비밀번호를 입력하세요.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                _buildEmailRow(),
                _buildPasswordRow(),
                _isRegistering ? _buildPasswordConfirmRow() : Container(),
                _buildConfirmButton(onConfirm: onSignIn),
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
            _showSnackBar('${_actionLabel}에 실패했습니다. 다시 시도해주세요.');
            return;
          }
      }
    }
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
      _showSnackBar('성공적으로 가입 되었습니다.');
    } else {
      switch (authResult.item2) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          {
            _showSnackBar('${_email}는 이미 사용 중인 메일 주소입니다. 로그인해주세요.');
            setState(() {
              _forceLoginView = true;
            });
            return;
          }
        case 'ERROR_WEAK_PASSWORD':
          {
            _showSnackBar('너무 쉬운 비밀번호입니다. 더 강력한 비밀번호로 다시 시도해주세요.');
            return;
          }
        default:
          {
            _showSnackBar('${_actionLabel}에 실패했습니다. 다시 시도해주세요.');
            return;
          }
      }
    }
  }

  Future<void> _onSendVerificationEmail() async {}

  Future<void> onSignIn() async {
    final userRepository = Provider.of<UserRepository>(context);

    setState(() {
      _status = LoginStatus.verifying;
    });

    final authResult = _isRegistering
        ? await userRepository.registerWithEmailAndPassword(
            email: _email,
            password: _password,
          )
        : await userRepository.loginWithEmailAndPassword(
            email: _email,
            password: _password,
          );

    setState(() {
      _status = LoginStatus.idle;
    });

    if (authResult.item1) {
      _showSnackBar(_isRegistering ? '성공적으로 가입 되었습니다.' : '성공적으로 로그인 되었습니다.');
    } else {
      print(authResult.item2);
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
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          {
            _showSnackBar('${_email}는 이미 사용 중인 메일 주소입니다. 로그인해주세요.');
            setState(() {
              _forceLoginView = true;
            });
            return;
          }
        default:
          {
            _showSnackBar('${_actionLabel}에 실패했습니다. 다시 시도해주세요.');
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
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: '비밀번호',
          helperText: _passwordHelperText,
        ),
        onChanged: (String password) {
          setState(() {
            _password = password;
            _status = LoginStatus.idle;
          });
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
      ),
    );
  }

  Widget _buildConfirmButton({OnConfirm onConfirm}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48),
          height: 48,
          child: RaisedButton(
            onPressed: _canConfirm ? onConfirm : null,
            child: Text(_actionLabel),
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
