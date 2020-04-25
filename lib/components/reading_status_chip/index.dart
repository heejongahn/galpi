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
      onTap: () => onTap(readingStatus),
      child: Opacity(
        opacity: isSelected ? 1 : 0.6,
        child: Chip(
          label: Text(label),
          backgroundColor: Colors.white,
          elevation: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
