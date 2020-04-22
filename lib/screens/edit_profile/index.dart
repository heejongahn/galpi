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

typedef void OnConfirm();

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
        title: Text('프로필 수정'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
        decoration: InputDecoration(
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
        },
        onChanged: (val) => setState(() {
          _displayName = val;
        }),
      ),
    );
  }

  Future getImage() async {
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

    await uploadFileToS3(
      file: image,
      url: signResult['signedUrl'],
    );

    setState(() {
      _profileImageUrl = signResult['objectUrl'];
    });
  }

  _onSave() async {
    final userRepository = Provider.of<UserRepository>(context);

    final map = userRepository.user.toMap();
    map['displayName'] = _displayName;
    map['profileImageUrl'] = _profileImageUrl;

    final updated = User.fromPayload(map);

    await userRepository.updateUser(updated);
    Navigator.of(context).pop();
  }
}
