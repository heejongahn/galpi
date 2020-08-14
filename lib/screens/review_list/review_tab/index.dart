import 'package:flutter/material.dart';
import 'package:galpi/components/infinite_scroll_list_view/index.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/components/review_card/main.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

const PAGE_SIZE = 20;

class ReviewTabState extends State<ReviewTab> {
  UniqueKey listViewKey = UniqueKey();

  var isInitialized = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final reviewRepository = Provider.of<ReviewRepository>(context);
      reviewRepository.initiailze();
      setState(() {
        isInitialized = true;
      });
    });
  }

  Widget _buildEmptyScreen() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            '작성한 독후감이 없습니다.\n시작하기 위해 첫 독후감을 작성해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);
    final reviewRepository = Provider.of<ReviewRepository>(context);

    return RefreshIndicator(
      onRefresh: () async {
        reviewRepository.initiailze();

        setState(() {
          listViewKey = UniqueKey();
        });

        return true;
      },
      child: isInitialized
          ? InfiniteScrollListView<Tuple2<Review, Book>>(
              key: listViewKey,
              data: reviewRepository.data,
              fetchMore: () => reviewRepository.fetchNextRead(
                userId: userRepository.user.id,
              ),
              emptyWidget: _buildEmptyScreen(),
              itemBuilder: _itemBuilder,
            )
          : Container(),
    );
  }

  void _onOpenReviewDetail(Review review, Book book, int index) {
    final args = ReviewDetailArguments(review.id);
    Navigator.of(context).pushNamed('/review/detail', arguments: args);
  }

  Widget _itemBuilder(Tuple2<Review, Book> pair, {int index}) {
    final review = pair.item1;
    final book = pair.item2;
    final userRepository = Provider.of<UserRepository>(context);

    return Container(
      child: ReviewCard(
        user: userRepository.user,
        review: review,
        book: book,
        onTap: () => _onOpenReviewDetail(review, book, index),
      ),
    );
  }
}

class ReviewTab extends StatefulWidget {
  @override
  ReviewTabState createState() => ReviewTabState();
}
