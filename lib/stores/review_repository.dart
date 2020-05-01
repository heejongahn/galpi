import 'package:flutter/widgets.dart';
import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';

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
}

final reviewRepository = ReviewRepository();
