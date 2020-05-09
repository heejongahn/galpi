import 'package:flutter/material.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:provider/provider.dart';

class EmailVerificationNeeded extends StatefulWidget {
  @override
  _EmailVerificationNeededState createState() =>
      _EmailVerificationNeededState();
}

typedef OnConfirm = void Function();

enum LoginStatus {
  idle,
  sendingEmail,
  sentEmail,
  verifying,
}

class _EmailVerificationNeededState extends State<EmailVerificationNeeded> {
  LoginStatus _status = LoginStatus.idle;

  @override
  void initState() {
    super.initState();
    final userRepository = Provider.of<UserRepository>(context, listen: false);

    if (userRepository.firebaseUser.isEmailVerified) {
      return;
    }

    setState(() {
      _status = LoginStatus.sendingEmail;
    });

    try {
      userRepository.sendVerificationEmail();
      setState(() {
        _status = LoginStatus.sentEmail;
      });
    } catch (e) {
      showMaterialSnackbar(context, '로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Logo(),
        centerTitle: false,
        actions: <Widget>[
          FlatButton(
            child: const Text('다른 계정으로 로그인'),
            onPressed: () async {
              await userRepository.logout();
            },
          )
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
                    '메일 인증',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Chip(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black87),
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    avatar: Icon(
                      Icons.person,
                      size: 16,
                    ),
                    backgroundColor: Colors.white,
                    label: Text(
                      userRepository.firebaseUser.email,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Text(
                    [
                      '갈피를 사용하기 전 마지막 단계입니다!',
                      '방금 위 주소로 인증 메일을 발송했습니다.',
                      '메일을 확인해 인증을 마친 뒤 아래 버튼을 눌러주세요.',
                    ].join('\n'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(height: 1.6),
                  ),
                ),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
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
            onPressed: _status == LoginStatus.sendingEmail
                ? null
                : _checkIfEmailVerified,
            child: const Text('인증을 완료했습니다'),
            color: Colors.black,
            textColor: Colors.white,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          height: 48,
          child: FlatButton(
            onPressed: _status == LoginStatus.sendingEmail ? null : _sendEmail,
            child: const Text('메일을 받지 못하셨나요?'),
          ),
        )
      ],
    );
  }

  Future<void> _checkIfEmailVerified() async {
    final userRepository = Provider.of<UserRepository>(context);
    final isVerified = await userRepository.checkIfEmailVerified();

    if (isVerified) {
      showMaterialSnackbar(context, '인증이 완료되었습니다.');
    } else {
      showMaterialSnackbar(context, '인증이 완료되지 않았습니다. 메일 확인 후 다시 시도해주세요.');
    }
  }

  Future<void> _sendEmail() async {
    final userRepository = Provider.of<UserRepository>(context);
    final isResending = _status != LoginStatus.idle;

    showMaterialSnackbar(context, '인증 메일을 ${isResending ? '다시 ' : ''}발송합니다.');

    setState(() {
      _status = LoginStatus.sendingEmail;
    });

    final email = userRepository.firebaseUser?.email;
    try {
      await userRepository.sendVerificationEmail();

      showMaterialSnackbar(
        context,
        '${email}로 인증 메일을 ${isResending ? '다시 ' : ''}발송했습니다.\n메일 애플리케이션 또는 사이트를 확인하세요.',
      );
      setState(() {
        _status = LoginStatus.sentEmail;
      });
    } catch (e) {
      showMaterialSnackbar(context, '로그인 중 오류가 발생했습니다. 다시 시도해주세요.');
      setState(() {
        _status = LoginStatus.idle;
      });
    }
  }
}
