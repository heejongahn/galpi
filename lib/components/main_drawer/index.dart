import 'package:flutter/material.dart';
import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/models/user.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, userRepository, child) {
      final isAuthenticated = userRepository.isLoggedIn;

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
                leading: Avatar(
                  profileImageUrl: userRepository.user?.profileImageUrl,
                ),
                title: Text(
                  this._getProfileSectionTitle(
                      userRepository.authStatus, userRepository.user),
                ),
                subtitle: Text(
                  this._getProfileSectionSubtitle(userRepository.authStatus),
                ),
              ),
            ),
            ...(isAuthenticated
                ? [
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('프로필 수정'),
                      onTap: () => _onEditProfile(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('로그아웃'),
                      onTap: () => _onSignOut(context),
                    )
                  ]
                : []),
            _buildAboutListTile(),
          ],
        ),
      );
    });
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

  _getProfileSectionTitle(AuthStatus authStatus, User user) {
    switch (authStatus) {
      case AuthStatus.Unauthenticated:
        {
          return '로그인 필요';
        }
      case AuthStatus.Authenticated:
        {
          return user.displayName ?? user.email;
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

  _onEditProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile/edit');
  }

  _onSignOut(BuildContext context) async {
    final onSignOutConfirm = (BuildContext dialogContext) async {
      await userRepository.logout();
      Navigator.of(dialogContext).pop();
      Navigator.of(context).pop();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('로그아웃 되었습니다.'),
      ));
    };

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
                child: Text("확인"),
                onPressed: () => onSignOutConfirm(ctx),
              ),
            ],
          );
        });
  }
}
