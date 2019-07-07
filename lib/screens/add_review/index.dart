import 'package:flutter/material.dart';

import 'package:galpi/components/review_form/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/database_helpers.dart';

import './search_view.dart';

class AddReview extends StatefulWidget {
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  Book selectedBook;
  FutureBuilder<List<Book>> searchResultBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('새 리뷰 작성'),
          centerTitle: false,
        ),
        body: selectedBook != null
            ? ReviewForm(
                book: selectedBook,
                review: new Review(stars: 0),
                onSave: _onCreate)
            : SearchView(onSelectBook: _onBookClick));
  }

  _onBookClick(Book book) {
    setState(() {
      selectedBook = book;
    });
  }

  Future<void> _onCreate(Review review, Book book) async {
    await DatabaseHelper.instance.insertReview(review, book);
    Navigator.of(context).pop();
  }
}
