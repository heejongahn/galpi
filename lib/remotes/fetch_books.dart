import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:galpi/utils/env.dart';
import 'package:http/http.dart' as http;
import 'package:galpi/models/book.dart' show Book;

const kakaoApiEndpoint = "https://dapi.kakao.com/v3/search/book";

Future<List<Book>> fetchBooks({
  @required String query,
  @required int page,
  @required int size,
}) async {
  if (query == '') {
    return Future.value([]);
  }

  final response = await http.get(
    '${kakaoApiEndpoint}?query=${query}&page=${page}&size=${size}',
    headers: {'Authorization': 'KakaoAK ${env.kakaoRestApiKey}'},
  );

  final decoded = json.decode(response.body) as Map<String, dynamic>;

  final books =
      List<Map<String, dynamic>>.from(decoded['documents'] as List<dynamic>);

  final bookIterable = books.map((data) => Book.fromKakaoPayload(data));
  final bookList = bookIterable.toList().cast<Book>();

  return bookList;
}
