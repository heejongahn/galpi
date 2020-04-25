import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/user.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<User> editProfile(User user) async {
  final url = '${env.apiEndpoint}/profile/edit';
  final body = const JsonEncoder().convert(user.toMap());

  final response = await httpClient.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);

  return User.fromPayload(decoded['user'] as Map<String, dynamic>);
}
