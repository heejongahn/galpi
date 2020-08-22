import 'package:flutter/material.dart';
import 'package:galpi/components/badge/index.dart';
import 'package:galpi/models/revision.dart';

typedef OnTap = void Function(ReadingStatus readingStatus);

class ReadingStatusBadge extends StatelessWidget {
  @required
  final ReadingStatus readingStatus;

  const ReadingStatusBadge({
    this.readingStatus,
  });

  IconData get avatarIcon {
    switch (readingStatus) {
      case ReadingStatus.reading:
        {
          return Icons.remove_red_eye;
        }
      case ReadingStatus.hasntStarted:
        {
          return Icons.shopping_cart;
        }
      case ReadingStatus.finishedReading:
        {
          return Icons.done;
        }
    }

    return null;
  }

  String get label {
    switch (readingStatus) {
      case ReadingStatus.reading:
        {
          return '읽는 중';
        }
      case ReadingStatus.hasntStarted:
        {
          return '읽기 전';
        }
      case ReadingStatus.finishedReading:
        {
          return '읽음';
        }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      iconData: avatarIcon,
      text: label,
    );
  }
}
