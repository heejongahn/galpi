import 'package:flutter/widgets.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/remotes/review/create.dart';
import 'package:galpi/remotes/review/create_revision.dart';
import 'package:galpi/remotes/review/create_unread.dart';
import 'package:galpi/remotes/review/delete.dart';

import 'package:galpi/remotes/review/list.dart';

const PAGE_SIZE = 20;

class ReviewRepository extends ChangeNotifier {
  List<Review> _data = [];

  List<Review> get data {
    return _data;
  }

  set data(List<Review> newData) {
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

  Future<void> create({
    Review review,
  }) async {
    await createReview(
      review: review,
    );
  }

  Future<void> addRevision({Review review}) async {
    await createRevision(review: review);
  }

  Future<void> createUnread({Book book}) async {
    final created = await createUnreadReview(book: book);
    data.insert(0, created);
  }

  Future<void> edit({Review review}) async {
    final updated = await createRevision(review: review);
    data = data.map((e) {
      if (e.id == review.id) {
        return updated;
      }

      return e;
    }).toList();
  }

  Future<void> delete({Review review}) async {
    await deleteReview(reviewId: review.id);
  }
}

final reviewRepository = ReviewRepository();
