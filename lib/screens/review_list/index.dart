import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/book_detail/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/components/review_form/index.dart';
import 'package:galpi/components/safe_area_route/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/database_helpers.dart';

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildRows(List<Review> reviews, List<Book> books) {
    return Flexible(
        child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: reviews.length,
            itemBuilder: (context, i) {
              final review = reviews[i];
              final book = books[i];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                child: ReviewCard(
                  review: reviews[i],
                  book: books[i],
                  onTap: () => _onOpenReviewDetail(review, book),
                  onEdit: () => _editReview(review, book),
                  onDelete: () => _deleteReview(review),
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: FutureBuilder<Tuple2<List<Review>, List<Book>>>(
            future: DatabaseHelper.instance.queryAllReviews(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reviews = snapshot.data.item1;
                final books = snapshot.data.item2;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '내 리뷰',
                      style: Theme.of(context).textTheme.display3.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    _buildRows(reviews, books),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return Center(child: CircularProgressIndicator());
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onOpenNewReview,
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteReview(Review review) {
    setState(() {
      DatabaseHelper.instance.deleteReview(review.id);
    });
  }

  void _editReview(Review review, Book book) async {
    await Navigator.of(context).push(SafeAreaRoute(
        child: Scaffold(
            body: ReviewForm(
                review: review,
                book: book,
                onSave: (Review newReview, Book _) async {
                  await DatabaseHelper.instance.updateReview(newReview, book);
                  Navigator.of(context).pop();
                }))));

    setState(() {});
  }

  void _onOpenReviewDetail(Review review, Book book) {
    Navigator.of(context)
        .push(SafeAreaRoute(child: BookDetail(review: review, book: book)));
  }

  void _onOpenNewReview() async {
    await Navigator.of(context).push(SafeAreaRoute(child: AddReview()));

    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => new ReviewsState();
}
