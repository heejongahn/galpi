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

      final onSignOut = () async {
        await userRepository.signOut();
      };

      final onClickSignIn = () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return PhoneAuth();
        }));
      };

      final onChangeDisplayName = (String newDisplayName) async {
        await userRepository.onSetDisplayName(displayName: newDisplayName);
      };

      final drawHeaderTitle = isAuthenticated
          ? (userRepository.user.displayName ?? '닉네임 없음')
          : '프로필 정보 없음';

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Text(drawHeaderTitle),
                trailing: GestureDetector(
                  child: Text(
                    '설정',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(fontSize: 12),
                  ),
                  onTap: () {
                    onClickSetDisplayName(context,
                        onConfirm: onChangeDisplayName,
                        currentDisplayName: userRepository.user.displayName);
                  },
                ),
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
