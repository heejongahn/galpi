import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/book.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

// TODO: 이 타입을 어떻게 써야할까?
// class CreateBookResponse {
//   String bookId;
// }

Future<String> createBook({Book book}) async {
  final url = '${env.apiEndpoint}/book/create';

  final body = JsonEncoder().convert({'bookPayload': book.toMap()});

  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  final decoded = httpClient.decodeBody(response.bodyBytes);
  return decoded['bookId'];
}
