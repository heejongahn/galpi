import 'package:flutter/material.dart';

typedef OnScoreBadgeTap = void Function(int score);

class ScoreChip extends StatelessWidget {
  @required
  final int score;
  @required
  final bool isSelected;

  final OnScoreBadgeTap onTap;

  const ScoreChip({this.score, this.isSelected = true, this.onTap});

  IconData get avatarIcon {
    switch (score) {
      case 0:
        return Icons.clear;
      case 1:
        return Icons.thumb_down;
      case 2:
        return Icons.thumbs_up_down;
      case 3:
        return Icons.thumb_up;
      case 4:
        return Icons.favorite;
      default:
        return Icons.thumbs_up_down;
    }
  }

  String get label {
    switch (score) {
      case 0:
        return '최악이에요';
      case 1:
        return '별로에요';
      case 2:
        return '보통이에요';
      case 3:
        return '추천해요';
      case 4:
        return '최고에요';
      default:
        return '보통이에요';
    }
  }

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(score);
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
          visualDensity: VisualDensity.compact,
          avatar: Icon(
            avatarIcon,
            size: 16,
          ),
          label: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.white,
          elevation: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
