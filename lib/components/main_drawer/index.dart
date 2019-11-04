import 'package:flutter/material.dart';
import 'package:galpi/components/input_dialog/index.dart';
import 'package:galpi/screens/phone_auth/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, userRepository, child) {
      final isAuthenticated = userRepository.isAuthenticated;

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
                      child: Text("확인"),
                      onPressed: () => onSignOutConfirm(ctx)),
                ],
              );
            });
      };

      final onClickSignIn = () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) {
                return PhoneAuth();
              },
              fullscreenDialog: true),
        );
      };

      final onChangeDisplayName = (String newDisplayName) async {
        await userRepository.onSetDisplayName(displayName: newDisplayName);
      };

      final drawerHeaderTitle = isAuthenticated
          ? (userRepository.user.displayName ?? '닉네임 없음')
          : '프로필 정보 없음';

      final drawerHeaderSubtitle =
          isAuthenticated ? '' : '휴대폰 인증으로 로그인하고 데이터 백업을 활성화하세요';

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
                title: Text(drawerHeaderTitle),
                subtitle: Text(drawerHeaderSubtitle),
                trailing: isAuthenticated
                    ? buildNicknameSettingButton(
                        context: context,
                        onChangeDisplayName: onChangeDisplayName,
                        currentDisplayName: userRepository.user.displayName)
                    : null,
              ),
            ),
            buildAboutListTile(),
            isAuthenticated
                ? ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('로그아웃'),
                    onTap: onSignOut,
                  )
                : ListTile(
                    leading: Icon(Icons.vpn_key),
                    title: Text('로그인'),
                    onTap: onClickSignIn,
                  ),
          ],
        ),
      );
    });
  }

  GestureDetector buildNicknameSettingButton({
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
        onClickSetDisplayName(
          context,
          onConfirm: onChangeDisplayName,
          currentDisplayName: currentDisplayName,
        );
      },
    );
  }

  FutureBuilder<PackageInfo> buildAboutListTile() {
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

  void onClickSetDisplayName(
    BuildContext ctx, {
    void onConfirm(String newDisplayName),
    String currentDisplayName,
  }) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return InputDialog(
            initialValue: currentDisplayName,
            title: "닉네임 설정",
            onConfirm: onConfirm,
            onClose: Navigator.of(context).pop,
          );
        });
    ;
  }
}
