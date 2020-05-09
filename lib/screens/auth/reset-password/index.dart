import 'package:flutter/material.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

enum LoginStatus {
  idle,
  sendingEmail,
  sentEmail,
  verifying,
}

class _ResetPasswordState extends State<ResetPassword> {
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
                  '비밀번호 재설정',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Text(
                '입력한 메일 주소로 비밀번호 재설정 메일이 전송됩니다.',
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
                : '${_email}로 메일이 발송되었습니다.'),
        onChanged: (String email) {
          setState(() {
            _email = email;
            _status = LoginStatus.idle;
          });
        },
        onSubmitted: (value) {
          _onSend();
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
            onPressed: _status == LoginStatus.idle ? _onSend : null,
            child: const Text('비밀번호 재설정'),
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
                      _status != LoginStatus.sendingEmail ? _onSend : null,
                  child: const Text('메일을 받지 못하셨나요?'),
                ),
              )
            : Container(width: 0, height: 0),
      ],
    );
  }

  Future<void> _onSend() async {
    final userRepository = Provider.of<UserRepository>(context);

    final isResending = _status != LoginStatus.idle;

    showMaterialSnackbar(
        context, '비밀번호 재설정 메일을 ${isResending ? '다시 ' : ''}발송합니다.');

    setState(() {
      _status = LoginStatus.sendingEmail;
    });

    try {
      await userRepository.sendPasswordResetEmail(email: _email);
      Scaffold.of(context).removeCurrentSnackBar();

      showMaterialSnackbar(
        context,
        '${_email}로 비밀번호 재설정 메일을 ${isResending ? '다시 ' : ''}발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
      );
      setState(() {
        _status = LoginStatus.sentEmail;
      });
    } catch (e) {
      showMaterialSnackbar(context, '메일 발송 중 오류가 발생했습니다. 다시 시도해주세요.');
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }
}
