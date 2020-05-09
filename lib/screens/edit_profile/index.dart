import 'package:flutter/services.dart';
import 'package:galpi/remotes/get_signed_url.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/models/user.dart';
import 'package:galpi/remotes/upload_file_to_s3.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:galpi/components/common_form/index.dart';
import 'package:galpi/stores/user_repository.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

typedef OnConfirm = void Function();

class _EditProfileState extends State<EditProfile> {
  String _profileImageUrl = '';
  String _displayName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final userRepository = Provider.of<UserRepository>(context);
    final user = userRepository.user;

    setState(() {
      _displayName = user.displayName;
      _profileImageUrl = user.profileImageUrl;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: CommonForm(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildProfileImageRow(),
              _buildDisplayNameRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageRow() {
    return GestureDetector(
      onTap: getImage,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Avatar(
              profileImageUrl: _profileImageUrl,
              size: 64,
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 16,
                  height: 16,
                  color: Colors.white,
                  child: Icon(
                    Icons.add,
                    size: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayNameRow() {
    final userRepository = Provider.of<UserRepository>(context);
    final user = userRepository.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: TextFormField(
        initialValue: user.displayName,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          labelText: '닉네임',
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return '내용을 입력해주세요.';
          }

          return null;
        },
        onChanged: (val) => setState(() {
          _displayName = val;
        }),
      ),
    );
  }

  Future<void> getImage() async {
    try {
      final image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 140,
        maxWidth: 140,
      );

      final filename = p.basename(image.path).replaceAll(
            'image_picker_',
            '',
          );

      final key = 'profile/$filename';

      final signResult = await getSignedUrl(key: key);

      print(signResult);

      await uploadFileToS3(
        file: image,
        url: signResult['signedUrl'] as String,
      );

      setState(() {
        _profileImageUrl = signResult['objectUrl'] as String;
      });
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("접근 권한 필요"),
              content: const Text(
                  '프로필 사진 변경을 위해선 사진 접근 권한이 필요합니다. 설정에서 “갈피” 어플리케이션의 사진 접근을 허용해주세요.'),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.black,
                  child: const Text("닫기"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        return;
      }

      rethrow;
    }
  }

  Future<void> _onSave() async {
    final userRepository = Provider.of<UserRepository>(context);

    final map = userRepository.user.toMap();
    map['displayName'] = _displayName;
    map['profileImageUrl'] = _profileImageUrl;

    final updated = User.fromPayload(map);

    await userRepository.updateUser(updated);
    Navigator.of(context).pop();
  }
}
