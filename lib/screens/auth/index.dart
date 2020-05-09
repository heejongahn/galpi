import 'package:flutter/material.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/components/logo/index.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

typedef OnConfirm = void Function();

enum LoginStatus {
  idle,
  verifying,
}
const rectBorder = RoundedRectangleBorder(
  side: BorderSide(color: Colors.black87),
  borderRadius: BorderRadius.all(
    Radius.circular(4),
  ),
);

class _AuthState extends State<Auth> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: null,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            title: Text('로그인'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            title: Text('회원가입'),
          ),
        ],
        currentIndex: _pageIndex,
        onTap: (int index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: CommonForm(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: const Logo(
                  fontSize: 90,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 48),
                child: Text(
                  '환영합니다.\n갈피에서 아름다운 독서 기록을 남기세요.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              _pageIndex == 0 ? loginBody : registerBody,
            ],
          ),
        ),
      ),
    );
  }

  Widget get loginBody {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 48,
          child: FlatButton(
            shape: rectBorder,
            onPressed: () {
              Navigator.of(context).pushNamed('/auth/email');
            },
            child: const Text('메일 인증으로 로그인'),
            color: Colors.white,
            textColor: Colors.black87,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 48,
          child: FlatButton(
            shape: rectBorder,
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/auth/login/email-password',
                arguments: {'isRegistering': false},
              );
            },
            child: const Text('메일 주소와 비밀번호로 로그인'),
            color: Colors.white,
            textColor: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget get registerBody {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 48,
          child: FlatButton(
            shape: rectBorder,
            onPressed: () {
              Navigator.of(context).pushNamed('/auth/email');
            },
            child: const Text('메일 인증으로 회원가입'),
            color: Colors.white,
            textColor: Colors.black87,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 48,
          child: FlatButton(
            shape: rectBorder,
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/auth/login/email-password',
                arguments: {'isRegistering': true},
              );
            },
            child: const Text('메일 주소와 비밀번호로 회원가입'),
            color: Colors.white,
            textColor: Colors.black87,
          ),
        )
      ],
    );
  }
}
