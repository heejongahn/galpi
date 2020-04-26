import 'package:flutter/material.dart';
import 'package:galpi/components/infinite_scroll_list_view/index.dart';
import 'package:galpi/components/logo/index.dart';
import 'package:galpi/components/main_drawer/index.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UniqueKey listViewKey = UniqueKey();

  var isInitialized = false;
  List<Tuple2<Review, Book>> data = [];

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
    return Consumer<UserRepository>(
      builder: (context, userRepository, _) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Logo(),
            centerTitle: false,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                data = [];
                isInitialized = false;
                listViewKey = UniqueKey();
              });

              return true;
            },
            child: InfiniteScrollListView<Tuple2<Review, Book>>(
              key: listViewKey,
              data: data,
              fetchMore: _fetchItems,
              emptyWidget: _buildEmptyScreen(),
              itemBuilder: _itemBuilder,
            ),
          ),
          endDrawer: const MainDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: _onOpenNewReview,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _onOpenReviewDetail(Review review, Book book) {
    final args = ReviewDetailArguments(review, book);
    Navigator.of(context).pushNamed('/review/detail', arguments: args);
  }

  Future<void> _onOpenNewReview() async {
    await Navigator.of(context).pushNamed('/review/add');
    setState(() {});
  }

  Widget _itemBuilder(Tuple2<Review, Book> pair) {
    final review = pair.item1;
    final book = pair.item2;

    return Container(
      child: ReviewCard(
        user: userRepository.user,
        review: review,
        book: book,
        onTap: () => _onOpenReviewDetail(review, book),
      ),
    );
  }

  Future<bool> _fetchItems() async {
    final items = await fetchReviews(
      userId: userRepository.user.id,
      skip: data.length,
      take: PAGE_SIZE,
    );

    setState(() {
      data = data + items;
      isInitialized = true;
    });

    return items.length == PAGE_SIZE;
  }
}

class Reviews extends StatefulWidget {
  @override
  ReviewsState createState() => ReviewsState();
}
