import 'dart:async';
import 'dart:convert';

import 'package:galpi/models/book.dart';
import 'package:galpi/utils/http_client.dart';
import 'package:galpi/utils/env.dart';

abstract class CreateBookResponse {
  String bookId;
}

Future<CreateBookResponse> createBook({Book book}) async {
  final url = '${env.apiEndpoint}/book/create';

  final body = JsonEncoder().convert({'bookPayload': book.toMap()});

  final response = await httpClient.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  try {
    final decoded = json.decode(response.body);

    return decoded;
  } catch (e) {
    return null;
  }
}
