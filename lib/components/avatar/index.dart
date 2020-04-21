import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String profileImageUrl;
  final double size;

  const Avatar({Key key, this.profileImageUrl, this.size = 32})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return profileImageUrl != null && profileImageUrl != ''
        ? ClipRRect(
            borderRadius: BorderRadius.circular(
              size / 2,
            ),
            child: Image.network(
              profileImageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          )
        : Icon(Icons.account_circle, size: size);
  }
}
