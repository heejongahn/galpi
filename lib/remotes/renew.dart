import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/auth_token_pair.dart' show AuthTokenPair;
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<AuthTokenPair> renew({String refreshToken}) async {
  final url = '${env.apiEndpoint}/auth/renew';
  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(
      {"refreshToken": refreshToken},
    ),
  );

  final body =
      Map<String, dynamic>.from(httpClient.decodeBody<Map<String, dynamic>>(
    response.bodyBytes,
  ));

  return AuthTokenPair.fromBody(body);
}
