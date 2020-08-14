import 'package:flutter/widgets.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/remotes/review/create.dart';
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

  List<Tuple2<Review, Book>> _unreadData = [];
  List<Tuple2<Review, Book>> get unreadData {
    return _unreadData;
  }

  set unreadData(List<Tuple2<Review, Book>> newData) {
    _unreadData = newData;
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
      active: true,
    );

    data = reviewRepository.data + items;

    return items.length == PAGE_SIZE;
  }

  Future<bool> fetchNextUnread({
    String userId,
  }) async {
    final items = await fetchReviews(
      userId: userId,
      skip: reviewRepository.data.length,
      take: PAGE_SIZE,
      active: false,
    );

    unreadData = reviewRepository.unreadData + items;

    return items.length == PAGE_SIZE;
  }

  Future<void> create({Review review, String bookId}) async {
    await createReview(review: review, bookId: bookId);
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
