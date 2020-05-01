import 'package:flutter/material.dart';
import 'package:galpi/models/review.dart';

typedef OnTap = void Function(ReadingStatus readingStatus);

class ReadingStatusChip extends StatelessWidget {
  @required
  final ReadingStatus readingStatus;

  @required
  final bool isSelected;

  final OnTap onTap;

  const ReadingStatusChip({
    this.readingStatus,
    this.isSelected = true,
    this.onTap,
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
    return GestureDetector(
      onTap: () {
        onTap?.call(readingStatus);
      },
      child: Opacity(
        opacity: isSelected ? 1 : 0.6,
        child: Chip(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black87),
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
          ),
          avatar: Icon(
            avatarIcon,
            size: 16,
          ),
          label: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          visualDensity: VisualDensity.compact,
          backgroundColor: Colors.white,
          elevation: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
