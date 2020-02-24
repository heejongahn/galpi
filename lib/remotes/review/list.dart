import 'dart:async';

import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/env.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:tuple/tuple.dart';

Future<List<Tuple2<Review, Book>>> fetchReviews({
  String userId,
  int skip = 0,
  int take = 20,
}) async {
  final response = await httpClient.get(
    '${env.apiEndpoint}/review/list?userId=${userId}&skip=${skip}&take=${take}',
    headers: {
      "Content-Type": "application/json; charset=utf-8",
    },
  );

  // final reviews = json.decode(utf8.decode(response.bodyBytes))['reviews'];
  final reviews = httpClient.decodeBody(response.bodyBytes)['reviews'];

  final reviewIterable = reviews.map((data) => Review.fromPayload(data));
  final reviewList = reviewIterable.toList().cast<Tuple2<Review, Book>>();

  return reviewList;
}
