import 'package:flutter/material.dart';
import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/models/user.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:launch_review/launch_review.dart';
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
              padding: const EdgeInsets.fromLTRB(0, 60, 0, 24),
              child: ListTile(
                leading: Avatar(
                  profileImageUrl: userRepository.user?.profileImageUrl,
                ),
                title: Text(
                  _getProfileSectionTitle(
                    userRepository.authStatus,
                    userRepository.user,
                  ),
                ),
                subtitle: Text(
                  _getProfileSectionSubtitle(
                    userRepository.authStatus,
                  ),
                ),
              ),
            ),
            ...isAuthenticated
                ? [
                    ListTile(
                      leading: Icon(Icons.edit),
                      title: const Text('프로필 수정'),
                      onTap: () => _onEditProfile(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.rate_review),
                      title: const Text('의견 남기기'),
                      onTap: _onWriteReview,
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: const Text('로그아웃'),
                      onTap: () => _onSignOut(context),
                    )
                  ]
                : [],
            const Divider(),
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
            applicationIcon: const Logo(),
            applicationName: '갈피',
            aboutBoxChildren: [
              const Text(
                '갈피는 아름다운 독후감 관리 앱입니다.',
              ),
            ],
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

  String _getProfileSectionTitle(AuthStatus authStatus, User user) {
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

    return null;
  }

  String _getProfileSectionSubtitle(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.Unauthenticated:
        {
          return '메일 주소로 로그인해\n데이터 백업을 활성화하세요';
        }
      case AuthStatus.Authenticated:
        {
          return '';
        }
    }

    return null;
  }

  void _onEditProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile/edit');
  }

  void _onWriteReview() {
    LaunchReview.launch(
      iOSAppId: '1470817706',
      androidAppId: 'name.ahnheejong.galpi',
    );
  }

  Future<void> _onSignOut(BuildContext context) async {
    final userRepository = Provider.of<UserRepository>(context);

    final onSignOutConfirm = (BuildContext dialogContext) async {
      await userRepository.logout();
      Navigator.of(dialogContext).pop();
      Navigator.of(context).pop();
      Scaffold.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃 되었습니다.'),
        ),
      );
    };

    showDialog<dynamic>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("정말 로그아웃합니까?"),
          actions: <Widget>[
            FlatButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            FlatButton(
              child: const Text("확인"),
              onPressed: () => onSignOutConfirm(ctx),
            ),
          ],
        );
      },
    );
  }
}
