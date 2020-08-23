import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Review> createRevision({
  Review review,
}) async {
  final url = '${env.apiEndpoint}/review/create-revision';

  final body = const JsonEncoder().convert({
    'revisionPayload': review.activeRevision.toMap(),
    'reviewId': review.id,
  });

  final response = await httpClient.post(
    url,
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);
  final createRevision =
      Map<String, dynamic>.from(decoded['review'] as Map<String, dynamic>);

  return Review.fromPayload(createRevision);
}
