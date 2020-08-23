import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> createReview({
  Review review,
}) async {
  final url = '${env.apiEndpoint}/review/create-review';

  final body = const JsonEncoder().convert({
    'reviewPayload': review.toMap(),
    'revisionPayload': review.activeRevision?.toMap(),
    'bookId': review.book.id,
  });

  final response = await httpClient.post(
    url,
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);
  final createdReviewPayload =
      Map<String, dynamic>.from(decoded['review'] as Map<String, dynamic>);

  return Review.fromPayload(createdReviewPayload);
}
