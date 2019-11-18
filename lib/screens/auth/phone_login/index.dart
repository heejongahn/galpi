import 'package:flutter/material.dart';
import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';

class PhoneAuth extends StatefulWidget {
  @override
  _PhoneAuthState createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  String _verificationId;
  String _phoneNumber = '';
  String _smsCode = '';
  int _currentStep = 0;
  bool isSendingSms = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, child) {
        onRequestSms() async {
          setState(() {
            isSendingSms = true;
          });

          final sendSmsResult =
              await userRepository.requestSms(phoneNumber: _phoneNumber);

          setState(() {
            isSendingSms = false;
          });

          switch (sendSmsResult.status) {
            case SendSmsStatus.CodeSent:
              {
                _verificationId = sendSmsResult.verificationId;
                _currentStep = 1;
                break;
              }
            case SendSmsStatus.AlreadyVerified:
              {
                try {
                  await userRepository
                      .signinWithCredential(sendSmsResult.authCredential);
                  _onSuccess();
                } catch (e) {
                  _onFail('로그인에 실패했습니다. 처음부터 다시 시도해주세요.');
                }

                break;
              }
            case SendSmsStatus.Error:
              {
                _onFail('로그인에 실패했습니다. 처음부터 다시 시도해주세요.');
                break;
              }
          }
        }

        onSignIn() async {
          try {
            final success = await userRepository.signInWithPhone(
              verificationId: _verificationId,
              smsCode: _smsCode,
            );

            if (success) {
              _onSuccess();
            }
          } catch (e) {
            _onFail('인증에 실패했습니다. 다시 시도해주세요.');
          }
        }

        onStepContinue() async {
          switch (_currentStep) {
            case 0:
              {
                await onRequestSms();
                break;
              }

            case 1:
              {
                await onSignIn();
                break;
              }

            default:
              {
                return;
              }
          }
        }

        onStepCancel() async {
          switch (_currentStep) {
            case 0:
              {
                _closeScreen();
                break;
              }

            case 1:
              {
                setState(() {
                  _smsCode = '';
                  _currentStep = 0;
                });
                break;
              }

            default:
              {
                return;
              }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('로그인'),
            centerTitle: false,
          ),
          body: CommonForm(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: onStepContinue,
              onStepCancel: onStepCancel,
              steps: [
                Step(
                  isActive: _currentStep == 0,
                  title: Text('휴대폰 번호 입력'),
                  content: buildPhoneNumberRow(
                    requestSms: userRepository.requestSms,
                    authStatus: userRepository.authStatus,
                  ),
                ),
                Step(
                  isActive: _currentStep == 1,
                  title: Text('인증번호 입력'),
                  content: buildSmsCodeRow(
                    userRepository.signInWithPhone,
                    context,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPhoneNumberRow({
    Future<SendSmsResult> requestSms({String phoneNumber}),
    AuthStatus authStatus,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(),
                helperText: isSendingSms ? '인증번호를 보내는 중입니다' : '',
              ),
              onChanged: (String phoneNumber) {
                setState(() {
                  _phoneNumber = phoneNumber;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmsCodeRow(
      Future<bool> signIn({String verificationId, String smsCode}),
      BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (String code) {
                setState(() {
                  _smsCode = code;
                });
              },
            ),
          ),
        ],
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

  _onSuccess() {
    _closeScreen();
    _showSnackbar('로그인에 성공했습니다.');
  }

  _onFail(String message) {
    _closeScreen();
    _showSnackbar(message);
  }

  _onBlur() {
    FocusScope.of(context).unfocus();
  }
}
