import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'package:booklog/screens/add_review/index.dart';
import 'package:booklog/components/review_card/main.dart';
import 'package:booklog/models/book.dart';
import 'package:booklog/models/review.dart';
import 'package:booklog/utils/database_helpers.dart';

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildRows(List<Review> reviews, List<Book> books) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reviews.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return ReviewCard(
            review: reviews[index],
            book: books[index],
            onDelete: () => _deleteReview(reviews[index]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('myreviews'),
      ),
      body: FutureBuilder<Tuple2<List<Review>, List<Book>>>(
          future: DatabaseHelper.instance.queryAllReviews(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final reviews = snapshot.data.item1;
              final books = snapshot.data.item2;
              return _buildRows(reviews, books);
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
    setState(() {
      DatabaseHelper.instance.deleteReview(review.id);
    });
  }

  void _onOpenNewReview() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AddReview();
    }));

    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => new ReviewsState();
}
