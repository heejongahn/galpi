import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/book.dart';
import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> createUnreadReview({
  Book book,
}) async {
  final url = '${env.apiEndpoint}/review/create-unread';

  final body = const JsonEncoder().convert({'bookPayload': book.toMap()});

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
