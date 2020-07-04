import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/components/markdown_content/index.dart';
import 'package:galpi/components/reading_status_chip/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:provider/provider.dart';

class ReviewPreviewArguments {
  final Review review;
  final Book book;

  ReviewPreviewArguments(this.review, this.book);
}

class ReviewPreview extends StatelessWidget {
  final ReviewPreviewArguments arguments;

  const ReviewPreview({Key key, @required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final review = arguments.review;
    final book = arguments.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text('미리보기'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BookInfo(book: book),
          getReviewDetail(context, review),
        ]),
      ),
    );
  }

  Padding getReviewDetail(BuildContext context, Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            review.title,
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          DateInfo(review: review),
          Wrap(
            spacing: 16,
            children: <Widget>[
              ReadingStatusChip(readingStatus: review.readingStatus),
              ScoreChip(
                score: review.stars,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: MarkdownContent(data: review.body),
          )
        ],
      ),
    );
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({
    @required this.review,
  });

  final Review review;
  final DateFormat formatter = DateFormat('yyyy년 M월 d일');

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /**
           * FIXME: 다른 유저의 글을 볼 수 있게되면 실제 저자의 정보로 변경
           */
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Avatar(
              profileImageUrl: userRepository.user.profileImageUrl,
              size: 40,
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              userRepository.user.displayName,
            ),
            review.createdAt != null
                ? Text(
                    '${formatter.format(review.createdAt)}',
                    style: Theme.of(context).textTheme.caption,
                  )
                : Container(),
          ]),
        ],
      ),
    );
  }
}
