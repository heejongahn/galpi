import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> createReview({
  Review review,
  String bookId,
}) async {
  final url = '${env.apiEndpoint}/review/create';

  final body = const JsonEncoder().convert({
    'reviewPayload': review.toMap(),
    'bookId': bookId,
  });

  final response = await httpClient.post(
    url,
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);
  final createdReviewPayload =
      Map<String, dynamic>.from(decoded['review'] as Map<String, dynamic>);

  final createdReview = Review.fromPayload(createdReviewPayload).item1;
  return createdReview;
}
