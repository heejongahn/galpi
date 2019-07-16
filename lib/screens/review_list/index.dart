import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/add_review/index.dart';
import 'package:galpi/screens/book_detail/index.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/database_helpers.dart';

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildEmptyScreen() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '작성한 독후감이 없습니다.\n시작하기 위해 첫 독후감을 작성해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildRows(List<Review> reviews, List<Book> books) {
    return ListView.builder(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'galpi',
          style: TextStyle(fontFamily: 'Abril-Fatface'),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: FutureBuilder<Tuple2<List<Review>, List<Book>>>(
            future: DatabaseHelper.instance.queryAllReviews(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reviews = snapshot.data.item1;
                final books = snapshot.data.item2;
                return reviews.length > 0
                    ? _buildRows(reviews, books)
                    : _buildEmptyScreen();
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
                  setState(() {
                    DatabaseHelper.instance.deleteReview(review.id);
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
  }

  void _editReview(Review review, Book book) async {
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

    setState(() {});
  }

  void _onOpenReviewDetail(Review review, Book book) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BookDetail(review: review, book: book)));
  }

  void _onOpenNewReview() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddReview()));

    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
