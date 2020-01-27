import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/env.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:tuple/tuple.dart';

Future<List<Tuple2<Review, Book>>> fetchReviews({String userId}) async {
  final response = await httpClient.get(
    '${env.apiEndpoint}/review/list?userId=${userId}',
  );

  final reviews = json.decode(response.body)['reviews'];

  final reviewIterable = reviews.map((data) => Review.fromPayload(data));
  final reviewList = reviewIterable.toList().cast<Tuple2<Review, Book>>();

  return reviewList;
}
