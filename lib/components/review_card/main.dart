import 'package:flutter/material.dart';
import 'package:booklog/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final GestureTapCallback onTap;

  ReviewCard({this.review, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Container(width: 0, height: 0);
    }

    return GestureDetector(
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                // Flexible(
                //     child: Container(
                //   child: Row(
                //       children: List(5)
                //           .map((i) => review.stars > i + 1
                //               ? Icon(Icons.star)
                //               : Icon(Icons.star_border))
                //           .toList()),
                // )),
                ListTile(
                  title: Text(
                    review.title,
                  ),
                  subtitle: Text(
                    '${review.body}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                )
              ]))),
      onTap: onTap,
    );
  }
}
