import 'package:galpi/components/reading_status_chip/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/remotes/review/delete.dart';
import 'package:galpi/remotes/review/edit.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/utils/show_error_dialog.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ReviewDetailArguments {
  final String reviewId;

  ReviewDetailArguments(this.reviewId);
}

class ReviewDetail extends StatelessWidget {
  final ReviewDetailArguments arguments;

  const ReviewDetail({Key key, @required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewBookPair = Provider.of<ReviewRepository>(context)
        .data
        .firstWhere((element) => element.item1.id == arguments.reviewId);
    final Review review = reviewBookPair.item1;
    final Book book = reviewBookPair.item2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('독후감'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(review.isPublic ? Icons.lock : Icons.lock_open),
            onPressed: () => _onEditPublicity(context, review),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _onEditReview(review, book, context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _onDeleteReview(review, context),
          ),
        ],
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
                  .headline2
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
              child: Text(
                review.body,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      fontSize: 16,
                      height: 1.6,
                    ),
              ),
            )
          ],
        ));
  }

  void _onDeleteReview(Review review, BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("정말 삭제하시겠습니까?"),
            content: const Text("삭제한 독후감는 다시 복구할 수 없습니다."),
            actions: <Widget>[
              FlatButton(
                child: const Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                textColor: Colors.red,
                child: const Text("삭제"),
                onPressed: () async {
                  await deleteReview(reviewId: review.id);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (Route<dynamic> r) => false,
                  );
                },
              ),
            ],
          );
        });
  }

  Future<void> _updateReview(BuildContext context, Review updatedReview) async {
    final reviewRepository = Provider.of<ReviewRepository>(context);

    try {
      final updated = await editReview(review: updatedReview);
      reviewRepository.data = reviewRepository.data.map((e) {
        if (e.item1.id == arguments.reviewId) {
          return Tuple2(updated, e.item2);
        }

        return e;
      }).toList();
    } catch (e) {
      showErrorDialog(context: context, message: '독후감 수정 중 오류가 발생했습니다.');
      rethrow;
    }
  }

  Future<void> _onEditPublicity(BuildContext context, Review review) async {
    try {
      final newIsPublic = !review.isPublic;
      review.isPublic = newIsPublic;
      await _updateReview(context, review);
      showMaterialSnackbar(
        context,
        newIsPublic ? '공개 독후감으로 변경했습니다.' : '비공개 독후감으로 변경했습니다.',
      );
    } catch (e) {
      showMaterialSnackbar(context, '수정에 실패했습니다.');
      rethrow;
    }
  }

  Future<void> _onEditReview(
      Review review, Book book, BuildContext context) async {
    await Navigator.of(context).pushNamed(
      '/review/write',
      arguments: WriteReviewArgument(
        isEditing: true,
        review: review,
        book: book,
        bookId: 'FIXME',
        onSave: (Review updatedReview, {String bookId}) async {
          try {
            await _updateReview(context, updatedReview);
            showMaterialSnackbar(context, '독후감을 수정했습니다.');
            return Navigator.of(context).pop();
          } catch (e) {
            showMaterialSnackbar(context, '독후감 수정에 실패했습니다.');
            rethrow;
          }
        },
      ),
    );
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({
    @required this.review,
  });

  final Review review;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          review.createdAt != null
              ? '${formatter.format(review.createdAt)} 작성'
              : '작성 일자 없음',
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
            review.lastModifiedAt != null
                ? '${formatter.format(review.lastModifiedAt)} 최종 수정'
                : '최종 수정 일자 없음',
            style: Theme.of(context).textTheme.caption)
      ]),
    );
  }
}
