import 'package:flutter/material.dart';
import 'package:galpi/components/badge/index.dart';

class ScoreBadge extends StatelessWidget {
  @required
  final int score;

  const ScoreBadge({
    this.score,
  });

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
  Widget build(BuildContext context) {
    return Badge(iconData: avatarIcon, text: label);
  }
}
