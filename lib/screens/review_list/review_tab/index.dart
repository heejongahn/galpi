import 'package:flutter/material.dart';
import 'package:galpi/components/badge/index.dart';
import 'package:galpi/components/book_card/main.dart';
import 'package:galpi/components/infinite_scroll_list_view/index.dart';
import 'package:galpi/components/reading_status_badge/index.dart';
import 'package:galpi/components/score_badge/index.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:provider/provider.dart';

import 'package:galpi/screens/review_detail/index.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/models/revision.dart';

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
          ? InfiniteScrollListView<Review>(
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

  void _onOpenReviewDetail(Review review, int index) {
    final args = ReviewDetailArguments(review.id);
    Navigator.of(context).pushNamed('/review/detail', arguments: args);
  }

  Widget _itemBuilder(Review review, {int index}) {
    if (review.activeRevision != null) {
      print(review.activeRevision);
    }

    final readingStatus = review.activeRevision?.readingStatus;

    return Container(
      child: BookCard(
        book: review.book,
        adornment: Container(
          margin: const EdgeInsets.only(top: 16),
          child: Wrap(
            spacing: 12,
            children: [
              ReadingStatusBadge(
                readingStatus: readingStatus ?? ReadingStatus.hasntStarted,
              ),
              if (readingStatus == ReadingStatus.finishedReading)
                ScoreBadge(
                  score: review.activeRevision?.stars,
                ),
              review.isPublic
                  ? const Badge(
                      iconData: Icons.lock_open,
                      text: '공개',
                    )
                  : const Badge(
                      iconData: Icons.lock,
                      text: '비공개',
                    ),
            ],
          ),
        ),
        onTap: () => _onOpenReviewDetail(review, index),
      ),
    );
  }
}

class ReviewTab extends StatefulWidget {
  @override
  ReviewTabState createState() => ReviewTabState();
}
