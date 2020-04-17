import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String profileImageUrl;

  const Avatar({Key key, this.profileImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return profileImageUrl != null && profileImageUrl != ''
        ? ClipRRect(
            borderRadius: BorderRadius.circular(
              16,
            ),
            child: Image.network(
              profileImageUrl,
              width: 32,
              height: 32,
            ),
          )
        : Icon(Icons.account_circle, size: 32);
  }
}
