import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/components/reading_status_chip/index.dart';
import 'package:galpi/components/score_chip/index.dart';
import 'package:galpi/stores/review_repository.dart';
import 'package:galpi/stores/user_repository.dart';
import 'package:galpi/utils/env.dart';
import 'package:galpi/utils/show_error_dialog.dart';
import 'package:galpi/utils/show_material_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:galpi/components/book_info/index.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/screens/write_review/index.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart' show Share;

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
          _buildShowBottomSheetButton(
            review: review,
            book: book,
            context: context,
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

  IconButton _buildShowBottomSheetButton(
      {Review review, Book book, BuildContext context}) {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (bottomSheetContext) {
            return SafeArea(
              child: Wrap(
                children: [
                  ...review.isPublic
                      ? [
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('비공개로 전환'),
                            onTap: () {
                              _onSetIsPublicToFalse(
                                context: context,
                                review: review,
                              );
                            },
                          )
                        ]
                      : [],
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('공유하기'),
                    onTap: () async {
                      final result = await _onSetIsPublicToTrue(
                        context: context,
                        review: review,
                      );

                      if (result) {
                        Navigator.of(bottomSheetContext).pop();
                        _onShare(review: review);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('수정하기'),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _onEditReview(review, book, context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      '삭제하기',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _onDeleteReview(review, context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
    final reviewRepository = Provider.of<ReviewRepository>(context);

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
                  await reviewRepository.delete(review: review);
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
      await reviewRepository.edit(review: updatedReview);
    } catch (e) {
      showErrorDialog(context: context, message: '독후감 수정 중 오류가 발생했습니다.');
      rethrow;
    }
  }

  Future<bool> _onSetIsPublicToTrue({
    BuildContext context,
    Review review,
  }) async {
    if (review.isPublic) {
      return true;
    }

    try {
      final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("공개 독후감으로 전환할까요?"),
                content: const Text(
                  "다른 사람들이 독후감을 볼 수 있게 됩니다. 언제든지 비공개로 전환할 수 있습니다.",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: const Text("취소"),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  FlatButton(
                    child: const Text("공개로 전환"),
                    onPressed: () async {
                      try {
                        review.isPublic = true;
                        await _updateReview(context, review);
                        Navigator.of(ctx).pop(true);
                      } catch (e) {
                        Navigator.of(ctx).pop(false);
                        rethrow;
                      }
                    },
                  ),
                ],
              );
            },
          ) ??
          false;

      if (result) {
        showMaterialSnackbar(
          context,
          '공개 독후감으로 전환했습니다.',
        );
      }

      return result;
    } catch (e) {
      review.isPublic = false;
      showMaterialSnackbar(
        context,
        '공개 독후감으로 전환하는 데 실패했습니다.',
      );
      rethrow;
    }
  }

  Future<void> _onSetIsPublicToFalse({
    BuildContext context,
    Review review,
    bool isPublic,
  }) async {
    if (!review.isPublic) {
      return true;
    }

    try {
      final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: const Text("비공개 독후감으로 전환할까요?"),
                content: const Text(
                  "이미 생성된 공유 링크에는 더 이상 접근할 수 없습니다. 언제든지 공개로 전환할 수 있습니다.",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: const Text("취소"),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  FlatButton(
                    child: const Text("비공개로 전환"),
                    onPressed: () async {
                      try {
                        review.isPublic = false;
                        await _updateReview(context, review);
                        Navigator.of(ctx).pop(true);
                      } catch (e) {
                        Navigator.of(ctx).pop(false);
                        rethrow;
                      }
                    },
                  ),
                ],
              );
            },
          ) ??
          false;

      if (result) {
        showMaterialSnackbar(
          context,
          '비공개 독후감으로 전환했습니다.',
        );
      }

      return result;
    } catch (e) {
      review.isPublic = true;
      showMaterialSnackbar(
        context,
        '비공개 독후감으로 전환하는 데 실패했습니다.',
      );
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

  Future<void> _onShare({Review review}) async {
    await Share.share(
      '${env.webEndpoint}/review/${review.id}',
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
