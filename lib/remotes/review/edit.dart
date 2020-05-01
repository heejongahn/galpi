import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> editReview({Review review}) async {
  final url = '${env.apiEndpoint}/review/edit';

  final body = const JsonEncoder().convert({
    'reviewPayload': review.toMap(),
  });

  final response = await httpClient.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);
  final updatedReviewPayload =
      Map<String, dynamic>.from(decoded['review'] as Map<String, dynamic>);

  final updatedReview = Review.fromPayload(updatedReviewPayload).item1;
  return updatedReview;
}
