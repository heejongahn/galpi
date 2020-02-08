import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/review.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<String> editReview({Review review}) async {
  final url = '${env.apiEndpoint}/review/edit';

  final body = JsonEncoder().convert({
    'reviewPayload': review.toMap(),
  });

  final response = await httpClient.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final decoded = httpClient.decodeBody(response.bodyBytes);
  return decoded['reviewId'];
}
