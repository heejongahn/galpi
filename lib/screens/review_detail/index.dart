import 'package:galpi/components/avatar/index.dart';
import 'package:galpi/components/markdown_content/index.dart';
import 'package:galpi/components/reading_status_badge/index.dart';
import 'package:galpi/components/score_badge/index.dart';
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

final DateFormat formatter = DateFormat('yyyy년 M월 d일');

class ReviewDetailArguments {
  final String reviewId;

  ReviewDetailArguments(this.reviewId);
}

class ReviewDetail extends StatelessWidget {
  final ReviewDetailArguments arguments;

  const ReviewDetail({Key key, @required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final review = Provider.of<ReviewRepository>(context)
        .data
        .firstWhere((element) => element.id == arguments.reviewId);
    final Book book = review.book;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: <Widget>[
          _buildShowBottomSheetButton(
            review: review,
            context: context,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BookInfo(book: book),
          review.activeRevision != null
              ? getReviewDetail(context, review)
              : getWriteReview(context, review),
        ]),
      ),
    );
  }

  IconButton _buildShowBottomSheetButton(
      {Review review, BuildContext context}) {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (bottomSheetContext) {
            return SafeArea(
              child: Wrap(
                children: [
                  if (review.activeRevision != null) ...[
                    if (review.isPublic)
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('비공개로 전환'),
                        onTap: () {
                          _onToggleIsPublic(
                            context: context,
                            review: review,
                          );
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('공유하기'),
                      onTap: () async {
                        if (!review.isPublic) {
                          final result = await _onToggleIsPublic(
                            context: context,
                            review: review,
                          );

                          if (!result) {
                            return;
                          }
                        }

                        Navigator.of(bottomSheetContext).pop();
                        _onShare(review: review);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('수정하기'),
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop();
                        _onEditReview(review, context);
                      },
                    ),
                  ],
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
    final activeRevision = review.activeRevision;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            activeRevision.title,
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          AuthorInfo(review: review),
          Wrap(
            spacing: 12,
            children: <Widget>[
              ReadingStatusBadge(readingStatus: activeRevision.readingStatus),
              ScoreBadge(
                score: activeRevision.stars,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: MarkdownContent(data: activeRevision.body),
          )
        ],
      ),
    );
  }

  Widget getWriteReview(BuildContext context, Review review) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 36,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.priority_high,
            size: 48,
          ),
          Container(
            margin: EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              '남긴 갈피가 없습니다',
              style: textTheme.headline5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 48),
            child: Text(
              '${formatter.format(review.createdAt)}에 추가됨',
              style: textTheme.caption,
            ),
          ),
          OutlineButton.icon(
            visualDensity: VisualDensity.standard,
            onPressed: () {
              _onEditReview(review, context);
            },
            icon: Icon(Icons.add_comment),
            label: const Text('갈피 남기기'),
          ),
        ],
      ),
    );
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
      },
    );
  }

  Future<void> _updateReview(BuildContext context, Review updatedReview) async {
    final reviewRepository = Provider.of<ReviewRepository>(context);

    try {
      await reviewRepository.saveRevision(review: updatedReview);
    } catch (e) {
      showErrorDialog(context: context, message: '독후감 수정 중 오류가 발생했습니다.');
      rethrow;
    }
  }

  Future<bool> _onToggleIsPublic({
    BuildContext context,
    Review review,
  }) async {
    final reviewRepository = Provider.of<ReviewRepository>(context);

    final nextIsPublic = !review.isPublic;

    final nextLabel = nextIsPublic ? '공개 독후감' : '비공개 독후감';
    final title = Text("${nextLabel}으로 전환할까요?");
    final content = nextIsPublic
        ? const Text(
            "다른 사람들이 독후감을 볼 수 있게 됩니다. 언제든지 비공개로 전환할 수 있습니다.",
          )
        : const Text(
            "이미 생성된 공유 링크에는 더 이상 접근할 수 없습니다. 언제든지 공개로 전환할 수 있습니다.",
          );

    final onPressed = (BuildContext dialogContext) async {
      try {
        review.isPublic = nextIsPublic;
        await reviewRepository.edit(review: review);
        Navigator.of(dialogContext).pop(true);
      } catch (e) {
        Navigator.of(dialogContext).pop(false);
        rethrow;
      }
    };

    try {
      final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: title,
              content: content,
              actions: <Widget>[
                FlatButton(
                  child: const Text("취소"),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                ),
                FlatButton(
                  child: nextIsPublic
                      ? const Text("공개로 전환")
                      : const Text("비공개로 전환"),
                  onPressed: () {
                    onPressed(dialogContext);
                  },
                ),
              ],
            ),
          ) ??
          false;

      if (result) {
        showMaterialSnackbar(
          context,
          '${nextLabel}으로 전환했습니다.',
        );
      }

      return result;
    } catch (e) {
      review.isPublic = !nextIsPublic;
      showMaterialSnackbar(
        context,
        '${nextLabel}으로 전환하는 데 실패했습니다.',
      );
      rethrow;
    }
  }

  Future<void> _onEditReview(Review review, BuildContext context) async {
    await Navigator.of(context).pushNamed(
      '/review/write',
      arguments: WriteReviewArgument(
        isEditing: true,
        review: review,
        onSave: (Review updatedReview) async {
          try {
            await _updateReview(context, updatedReview);
            showMaterialSnackbar(context, '독후감을 저장했습니다.');
            return Navigator.of(context).pop();
          } catch (e) {
            showMaterialSnackbar(context, '독후감 저장에 실패했습니다.');
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

class AuthorInfo extends StatelessWidget {
  const AuthorInfo({
    @required this.review,
  });

  final Review review;

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
            review.createdAt != null ? DateInfo(review: review) : Container(),
          ]),
        ],
      ),
    );
  }
}

class DateInfo extends StatelessWidget {
  const DateInfo({
    Key key,
    @required this.review,
  }) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${formatter.format(review.createdAt)}',
      style: Theme.of(context).textTheme.caption,
    );
  }
}
