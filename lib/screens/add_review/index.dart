import 'package:flutter/material.dart';

import 'package:booklog/models/book.dart';
import 'package:booklog/models/review.dart';
import 'package:booklog/utils/database_helpers.dart';

import './search_view.dart';
import './write_view.dart';

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
          title: Text('newreview'),
        ),
        body: selectedBook != null
            ? WriteView(selectedBook: selectedBook, onCreate: _onCreate)
            : SearchView(onSelectBook: _onBookClick));
  }

  _onBookClick(Book book) {
    setState(() {
      selectedBook = book;
    });
  }

  _onCreate(Review review) async {
    await DatabaseHelper.instance.insertReview(review);
    Navigator.of(context).pop();
  }
}
