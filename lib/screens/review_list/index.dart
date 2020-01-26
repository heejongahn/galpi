import 'package:flutter/material.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
import 'package:galpi/remotes/fetch_reviews.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

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

  Widget _buildRows(List<Tuple2<Review, Book>> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final review = data[i].item1;
        final book = data[i].item2;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: ReviewCard(
            review: review,
            book: book,
            onTap: () => _onOpenReviewDetail(review, book),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(
      builder: (context, userRepository, _) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Logo(),
            centerTitle: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: FutureBuilder<List<Tuple2<Review, Book>>>(
                future: fetchReviews(userId: userRepository.user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data.length > 0
                        ? _buildRows(snapshot.data)
                        : _buildEmptyScreen();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          ),
          endDrawer: MainDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: _onOpenNewReview,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _onOpenReviewDetail(Review review, Book book) {
    final args = new ReviewDetailArguments(review, book);
    Navigator.of(context).pushNamed('/review/detail', arguments: args);
  }

  void _onOpenNewReview() async {
    await Navigator.of(context).pushNamed('/review/add');
    setState(() {});
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
