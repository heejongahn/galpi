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
    return Scaffold(
        appBar: AppBar(title: Text('reviewww')),
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
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                            child: RichText(
                                text: TextSpan(children: [
                          TextSpan(
                              text: book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .copyWith()),
                          TextSpan(
                              text: ' ${book.author} | ${book.publisher}',
                              style: Theme.of(context).textTheme.caption)
                        ]))),
                      ]),
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
