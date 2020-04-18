import 'package:flutter/material.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
import 'package:galpi/models/user.dart';
import 'package:galpi/remotes/review/list.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

const PAGE_SIZE = 20;

enum Status {
  idle,
  loading,
  fetchedAll,
}

class ReviewsState extends State<Reviews> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var isInitialized = false;
  var status = Status.idle;
  List<Tuple2<Review, Book>> data = [];

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

  Widget _buildRows(List<Tuple2<Review, Book>> data, User user) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 72),
      itemCount: status == Status.fetchedAll ? data.length : null,
      itemBuilder: (context, i) {
        if (i > data.length) {
          return null;
        }

        if (i == data.length) {
          _fetchItems();

          if (!isInitialized) {
            final screenSize = MediaQuery.of(context).size;

            return SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (data.length == 0) {
            return Container();
          }

          return Container(
            padding: EdgeInsets.symmetric(
              vertical: 48,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }

        final review = data[i].item1;
        final book = data[i].item2;

        return Container(
          child: ReviewCard(
            user: user,
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
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                data = [];
                status = Status.idle;
                isInitialized = false;
              });

              await _fetchItems();

              return Future.value(true);
            },
            child: status == Status.fetchedAll && data.length == 0
                ? _buildEmptyScreen()
                : _buildRows(data, userRepository.user),
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

  Future<void> _fetchItems() async {
    if (status == Status.loading) {
      return;
    }

    status = Status.loading;

    final items = await fetchReviews(
      userId: userRepository.user.id,
      skip: data.length,
      take: PAGE_SIZE,
    );

    status = items.length == PAGE_SIZE ? Status.idle : Status.fetchedAll;

    setState(() {
      data = data + items;
      isInitialized = true;
    });
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
