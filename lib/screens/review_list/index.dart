import 'package:flutter/material.dart';

import 'package:booklog/screens/add_book/index.dart';
import 'package:booklog/components/review_card/main.dart';
import 'package:booklog/models/review.dart';
import 'package:booklog/utils/database_helpers.dart';

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildRows(List<Review> reviews) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reviews.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return ReviewCard(
            review: reviews[index],
            onDelete: () => _deleteReview(reviews[index]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('리뷰 피드'),
      ),
      body: FutureBuilder<List<Review>>(
          future: DatabaseHelper.instance.queryAllReviews(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildRows(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onOpenNewReview,
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteReview(Review review) {
    DatabaseHelper.instance.deleteReview(review.id);
  }

  void _onOpenNewReview() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AddBook();
    }));
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => new ReviewsState();
}
