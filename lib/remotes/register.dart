import 'dart:async';
import 'dart:convert';

import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<String> registerWithFirebase({String token}) async {
  final url = '${env.apiEndpoint}/register/firebase';
  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(
      {"token": token},
    ),
  );

  final body =
      Map<String, dynamic>.from(httpClient.decodeBody<Map<String, dynamic>>(
    response.bodyBytes,
  ));

  if (body['token'] != null) {
    return body['token'] as String;
  } else {
    throw 'registerWithFirebase failed';
  }
}
