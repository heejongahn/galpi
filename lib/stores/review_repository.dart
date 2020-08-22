import 'package:flutter/widgets.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/remotes/review/create.dart';
import 'package:galpi/remotes/review/create_revision.dart';
import 'package:galpi/remotes/review/create_unread.dart';
import 'package:galpi/remotes/review/delete.dart';
import 'package:galpi/remotes/review/edit.dart';

import 'package:galpi/remotes/review/list.dart';

import 'package:tuple/tuple.dart';

const PAGE_SIZE = 20;

class ReviewRepository extends ChangeNotifier {
  List<Tuple2<Review, Book>> _data = [];

  List<Tuple2<Review, Book>> get data {
    return _data;
  }

  set data(List<Tuple2<Review, Book>> newData) {
    _data = newData;
    notifyListeners();
  }

  void initiailze() {
    data = [];
  }

  Future<bool> fetchNextRead({
    String userId,
  }) async {
    final items = await fetchReviews(
      userId: userId,
      skip: reviewRepository.data.length,
      take: PAGE_SIZE,
      listType: ListType.all,
    );

    data = reviewRepository.data + items;

    return items.length == PAGE_SIZE;
  }

  Future<void> create({Review review, String bookId}) async {
    await createReview(review: review, bookId: bookId);
  }

  Future<void> addRevision({Review review}) async {
    await createRevision(review: review);
  }

  Future<void> createUnread({Book book}) async {
    final created = await createUnreadReview(book: book);
    data.insert(0, Tuple2(created, book));
  }

  Future<void> edit({Review review}) async {
    final updated = await editReview(review: review);
    data = data.map((e) {
      if (e.item1.id == review.id) {
        return Tuple2(updated, e.item2);
      }

      return e;
    }).toList();
  }

  Future<void> delete({Review review}) async {
    await deleteReview(reviewId: review.id);
  }
}

final reviewRepository = ReviewRepository();
