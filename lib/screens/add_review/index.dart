import 'package:flutter/material.dart';
import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/remotes/create_review.dart';

import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

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
        title: Text('새 독후감 작성'),
        centerTitle: false,
      ),
      body: SearchView(onSelectBook: _onBookClick),
    );
  }

  _onBookClick(Book book) async {
    final bookId = await createBook(book: book);

    Navigator.of(context).pushNamed(
      '/review/write',
      arguments: WriteReviewArgument(
        review: Review(stars: 2),
        book: book,
        bookId: bookId,
        onSave: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Review review, String bookId) async {
    await createReview(review: review, bookId: bookId);
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route r) => false);
  }
}
