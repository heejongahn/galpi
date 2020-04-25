import 'dart:async';

import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Map<String, dynamic>> getSignedUrl({String key}) async {
  final url = '${env.apiEndpoint}/file/get-signed-url?key=$key';

  final response = await httpClient.post(url);
  final body = httpClient.decodeBody<Map<String, dynamic>>(
    response.bodyBytes,
  );

  return body;
}
