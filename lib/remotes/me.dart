import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/user.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<User> me() async {
  final url = '${env.apiEndpoint}/me';
  final response = await httpClient.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  final decoded = httpClient.decodeBody(response.bodyBytes);

  return User.fromPayload(decoded['user']);
}
