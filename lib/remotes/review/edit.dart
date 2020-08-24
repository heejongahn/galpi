import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> editReview({
  Review review,
}) async {
  final url = '${env.apiEndpoint}/review/edit-review';

  final body = const JsonEncoder().convert({
    'reviewPayload': review.toMap(),
  });

  final response = await httpClient.put(
    url,
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);
  final createdReviewPayload =
      Map<String, dynamic>.from(decoded['review'] as Map<String, dynamic>);

  return Review.fromPayload(createdReviewPayload);
}
