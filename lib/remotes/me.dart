import 'dart:async';

import 'package:galpi/models/user.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<User> me() async {
  final url = '${env.apiEndpoint}/me';
  final response = await httpClient.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);

  return User.fromJson(decoded['user'] as Map<String, dynamic>);
}
