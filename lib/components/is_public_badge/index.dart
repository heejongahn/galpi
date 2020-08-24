import 'package:flutter/material.dart';
import 'package:galpi/components/badge/index.dart';

class IsPublicBadge extends StatelessWidget {
  @required
  final bool isPublic;

  const IsPublicBadge({
    this.isPublic,
  });

  @override
  Widget build(BuildContext context) {
    return isPublic
        ? const Badge(
            iconData: Icons.lock_open,
            text: '공개',
          )
        : const Badge(
            iconData: Icons.lock,
            text: '비공개',
          );
  }
}
