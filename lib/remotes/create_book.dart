import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/book.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

Future<Book> createBook({Book book}) async {
  final url = '${env.apiEndpoint}/book/create';

  final body = const JsonEncoder().convert(
    {
      'bookPayload': book.toJson(),
    },
  );

  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final decoded =
      httpClient.decodeBody<Map<String, dynamic>>(response.bodyBytes);

  final createdBookPayload =
      Map<String, dynamic>.from(decoded['book'] as Map<String, dynamic>);

  return Book.fromJson(createdBookPayload);
}
