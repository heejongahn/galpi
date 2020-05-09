import 'package:flutter/material.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

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
                  '메일 인증',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text(
                '입력한 메일 주소로 인증 메일이 전송됩니다.',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              _buildEmailRow(),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailRow({
    AuthStatus authStatus,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.send,
        enabled: _status != LoginStatus.verifying,
        autofocus: true,
        decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: '메일 주소',
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
        onSubmitted: (value) {
          _onSignIn();
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: RaisedButton(
            onPressed: _status == LoginStatus.idle ? _onSignIn : null,
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
                      _status != LoginStatus.sendingEmail ? _onSignIn : null,
                  child: const Text('메일을 받지 못하셨나요?'),
                ),
              )
            : Container(width: 0, height: 0),
      ],
    );
  }

  Future<void> _onSignIn() async {
    final userRepository = Provider.of<UserRepository>(context);

    final isResending = _status != LoginStatus.idle;

    showMaterialSnackbar(context, '인증 메일을 ${isResending ? '다시 ' : ''}발송합니다.');

    setState(() {
      _status = LoginStatus.sendingEmail;
    });

    final success = await userRepository.sendLoginEmail(email: _email);
    Scaffold.of(context).removeCurrentSnackBar();

    if (success) {
      showMaterialSnackbar(
        context,
        '${_email}로 인증 메일을 ${isResending ? '다시 ' : ''}발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
      );
      setState(() {
        _status = LoginStatus.sentEmail;
      });
    } else {
      showMaterialSnackbar(context, '로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }
}
