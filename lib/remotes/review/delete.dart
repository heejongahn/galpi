import 'dart:async';

import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<void> deleteReview({String reviewId}) async {
  final url = '${env.apiEndpoint}/review/delete?reviewId=$reviewId';

  await httpClient.delete(
    url,
    headers: {"Content-Type": "application/json"},
  );
}
