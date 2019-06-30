import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/stars_row/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

class BookDetail extends StatelessWidget {
  final Review review;
  final Book book;

  const BookDetail({Key key, this.review, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    review.title,
                    style: Theme.of(context).textTheme.display3.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(book.title,
                      style: Theme.of(context).textTheme.headline.copyWith()),
                  Text('${book.author} | ${book.publisher}',
                      style: Theme.of(context).textTheme.subhead),
                  DateInfo(review: review, formatter: formatter),
                  Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      label: Text(review.displayReadingStatus),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(fontSize: 12, color: Colors.white),
                      labelPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 4)),
                  StarsRow(
                    stars: review.stars,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(review.body,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontSize: 16)))
                ]))));
  }
}

class DateInfo extends StatelessWidget {
  const DateInfo({
    Key key,
    @required this.review,
    @required this.formatter,
  }) : super(key: key);

  final Review review;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          review.createdAt != null
              ? '${formatter.format(review.createdAt)} 작성'
              : '작성 일자 없음',
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
            review.lastModifiedAt != null
                ? '${formatter.format(review.lastModifiedAt)} 최종 수정'
                : '최종 수정 일자 없음',
            style: Theme.of(context).textTheme.caption)
      ]),
    );
  }
}
