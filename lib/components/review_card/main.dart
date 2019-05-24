import 'package:flutter/material.dart';
import 'package:booklog/models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final GestureTapCallback onTap;
  final VoidCallback onDelete;

  ReviewCard({this.review, this.onTap, this.onDelete});

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
                ListTile(
                  title: Text(
                    review.title,
                  ),
                  subtitle: Text(
                    '${review.body}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  trailing: RaisedButton(
                    child: Text('삭제'),
                    onPressed: onDelete,
                  ),
                ),
                Container(
                  child: Row(
                      children: List<int>.generate(5, (i) => i + 1)
                          .map((i) => review.stars >= i
                              ? Icon(Icons.star)
                              : Icon(Icons.star_border))
                          .toList()),
                ),
              ]))),
      onTap: onTap,
    );
  }
}
