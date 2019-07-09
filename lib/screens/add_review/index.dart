import 'package:flutter/material.dart';

import 'package:galpi/screens/review_list/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/database_helpers.dart';

import './search_view.dart';

class AddReview extends StatefulWidget {
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  FutureBuilder<List<Book>> searchResultBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('새 리뷰 작성'),
          centerTitle: false,
        ),
        body: SearchView(onSelectBook: _onBookClick));
  }

  _onBookClick(Book book) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WriteReview(
            review: Review(stars: 0), book: book, onSave: _onCreate)));
  }

  Future<void> _onCreate(Review review, Book book) async {
    await DatabaseHelper.instance.insertReview(review, book);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) {
      return Reviews();
    }), (Route r) => false);
  }
}
