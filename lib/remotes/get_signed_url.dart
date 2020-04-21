import 'dart:async';

import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Map<String, String>> getSignedUrl({String key}) async {
  final url = '${env.apiEndpoint}/file/get-signed-url?key=$key';

  final response = await httpClient.post(url);
  final body = Map<String, String>.from(
    httpClient.decodeBody(
      response.bodyBytes,
    ),
  );

  return body;
}
