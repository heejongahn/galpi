import 'package:flutter/material.dart';
import 'package:galpi/remotes/create_book.dart';
import 'package:galpi/remotes/review/create.dart';

import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/show_error_dialog.dart';

import './search_view.dart';

class AddReview extends StatefulWidget {
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  FutureBuilder<List<Book>> searchResultBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 독후감 작성'),
        centerTitle: false,
      ),
      body: SearchView(onSelectBook: _onBookClick),
    );
  }

  Future<void> _onBookClick(Book book) async {
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

  Future<void> _onCreate(Review review, {String bookId}) async {
    try {
      await createReview(review: review, bookId: bookId);
      Navigator.pushNamedAndRemoveUntil(
          context, '/', (Route<dynamic> r) => false);
    } catch (e) {
      print(e);
      showErrorDialog(context: context, message: '독후감 작성 중 오류가 발생했습니다.');
    }
  }
}
