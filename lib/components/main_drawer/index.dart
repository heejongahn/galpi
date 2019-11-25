import 'package:flutter/material.dart';
import 'package:galpi/components/input_dialog/index.dart';
import 'package:galpi/screens/auth/email_login/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, userRepository, child) {
      final isAuthenticated = userRepository.isLoggedIn;

      final onSignOutConfirm = (BuildContext dialogContext) async {
        await userRepository.signOut();
        Navigator.of(dialogContext).pop();
        Navigator.of(context).pop();
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('로그아웃 되었습니다.'),
        ));
      };

      final onSignOut = () async {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("정말 로그아웃합니까?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("취소"),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
                FlatButton(
                    child: Text("확인"), onPressed: () => onSignOutConfirm(ctx)),
              ],
            );
          },
        );
      };

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: Divider.createBorderSide(context),
                ),
              ),
              padding: EdgeInsets.fromLTRB(0, 60, 0, 24),
              child: ListTile(
                leading: Icon(Icons.account_circle, size: 32),
                title: Text(
                    this._getProfileSectionTitle(userRepository.authStatus)),
                subtitle: Text(
                  this._getProfileSectionSubtitle(userRepository.authStatus),
                ),
              ),
            ),
            ...(isAuthenticated
                ? [
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('로그아웃'),
                      onTap: onSignOut,
                    )
                  ]
                : [
                    ListTile(
                      leading: Icon(Icons.vpn_key),
                      title: Text('로그인'),
                      onTap: () => onClickLogin(context),
                    ),
                  ]),
            _buildAboutListTile(),
          ],
        ),
      );
    });
  }

  onClickLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EmailLogin();
        },
        fullscreenDialog: true,
      ),
    );
  }

  GestureDetector _buildNicknameSettingButton({
    BuildContext context,
    Future<dynamic> onChangeDisplayName(String newDisplayName),
    String currentDisplayName,
  }) {
    return GestureDetector(
      child: Text(
        '설정',
        style: Theme.of(context).textTheme.button.copyWith(fontSize: 12),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return InputDialog(
              initialValue: currentDisplayName,
              title: "닉네임 설정",
              onConfirm: onChangeDisplayName,
              onClose: Navigator.of(context).pop,
            );
          },
        );
      },
    );
  }

  FutureBuilder<PackageInfo> _buildAboutListTile() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'galpi',
            applicationVersion: snapshot.data.version,
          );
        }

        return AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'galpi',
        );
      },
    );
  }

  _getProfileSectionTitle(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.Unauthenticated:
        {
          return '로그인 필요';
        }
      case AuthStatus.Authenticated:
        {
          return (userRepository.user != null &&
                  userRepository.user.displayName != null)
              ? userRepository.user.displayName
              : '프로필 없음';
        }
    }
  }

  _getProfileSectionSubtitle(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.Unauthenticated:
        {
          return '이메일 주소로 로그인해\n데이터 백업을 활성화하세요';
        }
      case AuthStatus.Authenticated:
        {
          return '';
        }
    }
  }
}
