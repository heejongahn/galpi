import 'package:flutter/material.dart';
import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd');

class ReviewCard extends StatelessWidget {
  final Review review;
  final Book book;
  final GestureTapCallback onTap;

  ReviewCard({
    this.review,
    this.book,
    this.onTap,
  });

  buildBookDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 8,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(
              review.title,
              style: Theme.of(context).textTheme.title,
            ),
            subtitle: Text(review.displayCreatedDate,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Container(width: 0, height: 0);
    }

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BookInfo(book: book),
            buildBookDescription(context),
            // moreIcon
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
