import 'package:flutter/material.dart';

typedef OnTapStar = void Function(int stars);

class StarsRow extends StatelessWidget {
  final int stars;
  final double size;
  final OnTapStar onTapStar;

  const StarsRow({Key key, this.stars = 0, this.size = 16, this.onTapStar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List<int>.generate(5, (i) => i + 1)
            .map((i) => GestureDetector(
                  onTap: () => onTapStar(i),
                  child: Icon(
                    (stars ?? 0) >= i ? Icons.star : Icons.star_border,
                    size: size,
                  ),
                ))
            .toList());
  }
}
