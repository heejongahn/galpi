import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

class CreateReviewResponse {
  String reviewId;
}

Future<CreateReviewResponse> createReview(
    {Review review, String bookId}) async {
  final url = '${env.apiEndpoint}/review/create';

  final body = JsonEncoder().convert({
    'reviewPayload': review.toMap(bookId),
    'bookId': bookId,
  });

  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  try {
    final decoded = json.decode(response.body);
    return decoded;
  } catch (e) {
    return null;
  }
}
