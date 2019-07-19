import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/components/stars_row/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/screens/review_list/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/utils/database_helpers.dart';

class ReviewDetail extends StatelessWidget {
  final Review review;
  final Book book;

  const ReviewDetail({Key key, this.review, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('독후감'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _onEditReview(review, book, context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _onDeleteReview(review, context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BookInfo(book: book),
          getReviewDetail(context),
        ]),
      ),
    );
  }

  Padding getReviewDetail(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              review.title,
              style: Theme.of(context)
                  .textTheme
                  .display3
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            DateInfo(review: review),
            Chip(
                backgroundColor: Theme.of(context).primaryColor,
                label: Text(review.displayReadingStatus),
                labelStyle: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(fontSize: 12, color: Colors.white),
                labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4)),
            StarsRow(
              stars: review.stars,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(review.body,
                  style:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 16)),
            )
          ],
        ));
  }

  void _onDeleteReview(Review review, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("정말 삭제하시겠습니까?"),
            content: Text("삭제한 독후감는 다시 복구할 수 없습니다."),
            actions: <Widget>[
              FlatButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                textColor: Colors.red,
                child: Text("삭제"),
                onPressed: () {
                  DatabaseHelper.instance.deleteReview(review.id);
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (ctx) {
                    return Reviews();
                  }), (Route r) => false);
                },
              ),
            ],
          );
        });
  }

  void _onEditReview(Review review, Book book, BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WriteReview(
          isEditing: true,
          review: review,
          book: book,
          onSave: (Review newReview, Book _) async {
            await DatabaseHelper.instance.updateReview(newReview, book);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({
    @required this.review,
  });

  final Review review;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

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
