import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:booklog/components/stars_row/index.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/models/review.dart';

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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                  ),
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
