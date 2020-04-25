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
        return Icons.sentiment_very_dissatisfied;
      case 1:
        return Icons.sentiment_dissatisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_satisfied;
      case 4:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
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
      onTap: () => onTap(score),
      child: Opacity(
        opacity: isSelected ? 1 : 0.6,
        child: Chip(
          avatar: Icon(avatarIcon),
          label: Text(label),
          backgroundColor: Colors.white,
          elevation: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}
